import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public typealias PasswordProvider = @Sendable () async throws -> String

public struct AshClientOptions: Sendable {
    public var baseURL: URL
    public var passwordProvider: PasswordProvider
    public var policy: ASHCallPolicy
    public var timeout: TimeInterval

    public init(
        baseURL: URL = URL(string: "http://127.0.0.1:60080")!,
        passwordProvider: @escaping PasswordProvider,
        policy: @escaping ASHCallPolicy = ASHPolicies.allowAll,
        timeout: TimeInterval = 15
    ) {
        self.baseURL = baseURL
        self.passwordProvider = passwordProvider
        self.policy = policy
        self.timeout = timeout
    }
}

public final class AshClient: @unchecked Sendable {
    public let options: AshClientOptions
    private let session: URLSession
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    public init(options: AshClientOptions, session: URLSession = .shared) {
        self.options = options
        self.session = session
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
    }

    public func call(_ function: String, _ args: any ASHArgumentConvertible...) async throws -> JSONValue {
        try await call(function, arguments: args.map(\.ashJSONValue))
    }

    public func call(_ function: String, arguments: [JSONValue]) async throws -> JSONValue {
        try options.policy(function, arguments)
        let response = try await batch(ASHBatchRequest(functions: [ASHFunctionCall(name: function, args: arguments)]))
        guard let first = response.functions.first else {
            throw ASHError.malformedResponse("Function response missing for \(function)")
        }
        return first
    }

    public func property(_ name: String) async throws -> JSONValue {
        let response = try await batch(ASHBatchRequest(properties: [name]))
        guard let first = response.properties.first else {
            throw ASHError.malformedResponse("Property response missing for \(name)")
        }
        return first
    }

    public func batch(_ request: ASHBatchRequest) async throws -> ASHBatchResponse {
        for function in request.functions {
            try options.policy(function.name, function.args)
        }

        let wire = WireRequest(
            properties: request.properties.isEmpty ? nil : request.properties,
            functions: request.functions.isEmpty ? nil : request.functions
        )
        let bodyJSON: Data
        do {
            bodyJSON = try encoder.encode(wire)
        } catch {
            throw ASHError.malformedResponse("Could not encode request: \(error)")
        }
        guard let jsonString = String(data: bodyJSON, encoding: .utf8) else {
            throw ASHError.malformedResponse("Request JSON was not UTF-8")
        }

        let pwd: String
        do {
            pwd = try await options.passwordProvider()
        } catch {
            throw ASHError.passwordProvider(String(describing: error))
        }

        let endpoint = options.baseURL.appendingPathComponent("KoLmafia/jsonApi")
        var urlRequest = URLRequest(url: endpoint, timeoutInterval: options.timeout)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = Self.formEncode(["pwd": pwd, "body": jsonString]).data(using: .utf8)

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: urlRequest)
        } catch {
            throw ASHError.transport(String(describing: error))
        }

        guard let http = response as? HTTPURLResponse else {
            throw ASHError.transport("Non-HTTP response")
        }
        guard (200..<300).contains(http.statusCode) else {
            throw ASHError.httpStatus(http.statusCode, String(data: data, encoding: .utf8) ?? "<non-UTF8 body>")
        }

        let decoded: WireResponse
        do {
            decoded = try decoder.decode(WireResponse.self, from: data)
        } catch {
            throw ASHError.malformedResponse("Could not decode JSON response: \(error)")
        }
        if let error = decoded.error {
            throw ASHError.api(error)
        }

        return ASHBatchResponse(
            properties: decoded.properties ?? [],
            functions: decoded.functions ?? []
        )
    }

    private static func formEncode(_ values: [String: String]) -> String {
        values.keys.sorted().map { key in
            "\(percentEncode(key))=\(percentEncode(values[key]!))"
        }.joined(separator: "&")
    }

    private static func percentEncode(_ value: String) -> String {
        var allowed = CharacterSet.alphanumerics
        allowed.insert(charactersIn: "-._~")
        return value.addingPercentEncoding(withAllowedCharacters: allowed) ?? value
    }
}
