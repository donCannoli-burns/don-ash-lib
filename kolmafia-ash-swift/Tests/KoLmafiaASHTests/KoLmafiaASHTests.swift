import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Testing
@testable import KoLmafiaASH

final class StubURLProtocol: URLProtocol {
    nonisolated(unsafe) static var handler: (@Sendable (URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        do {
            guard let handler = Self.handler else { throw NSError(domain: "Stub", code: 1) }
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

func makeSession() -> URLSession {
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [StubURLProtocol.self]
    return URLSession(configuration: config)
}

@Suite(.serialized)
struct KoLmafiaASHTests {
@Test func enumSerialization() throws {
    let value = Item("filthy lucre").ashJSONValue
    #expect(value == .object([
        "objectType": .string("Item"),
        "identifierString": .string("filthy lucre")
    ]))
    #expect(Item(id: 1).ashJSONValue == .object([
        "objectType": .string("Item"),
        "identifierNumber": .integer(1)
    ]))
}

@Test func transportBatchingAndFormEncoding() async throws {
    StubURLProtocol.handler = { request in
        #expect(request.url?.path == "/KoLmafia/jsonApi")
        #expect(request.httpMethod == "POST")
        #expect(request.value(forHTTPHeaderField: "Content-Type")?.hasPrefix("application/x-www-form-urlencoded") == true)
        let body = String(data: request.httpBody ?? Data(), encoding: .utf8) ?? ""
        #expect(body.contains("pwd=a%2Bb%26c%3Dd"))
        #expect(body.contains("body="))

        let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: ["Content-Type": "application/json"])!
        let payload = #"{"properties":[true],"functions":["Tester",123,2]}"#.data(using: .utf8)!
        return (response, payload)
    }

    let client = AshClient(options: AshClientOptions(passwordProvider: { "a+b&c=d" }), session: makeSession())
    let result = try await client.batch(ASHBatchRequest(
        properties: ["kingLiberated"],
        functions: [
            ASHFunctionCall(name: "myName"),
            ASHFunctionCall(name: "myMeat"),
            ASHFunctionCall("availableAmount", Item("filthy lucre"))
        ]
    ))
    #expect(result.properties == [.bool(true)])
    #expect(result.functions == [.string("Tester"), .integer(123), .integer(2)])
}

@Test func policyRejectsBeforeTransport() async throws {
    nonisolated(unsafe) var hitTransport = false
    StubURLProtocol.handler = { request in
        hitTransport = true
        let response = HTTPURLResponse(url: request.url!, statusCode: 500, httpVersion: nil, headerFields: nil)!
        return (response, Data())
    }
    let client = AshClient(options: AshClientOptions(
        passwordProvider: { "pwd" },
        policy: ASHPolicies.deny("cliExecute")
    ), session: makeSession())

    do {
        _ = try await client.call("cliExecute", "status")
        Issue.record("Expected policy denial")
    } catch let error as ASHError {
        #expect(error == .policyDenied(function: "cliExecute"))
    }
    #expect(hitTransport == false)
}

@Test func typedHelpers() async throws {
    StubURLProtocol.handler = { request in
        let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        let payload = #"{"functions":[42]}"#.data(using: .utf8)!
        return (response, payload)
    }
    let client = AshClient(options: AshClientOptions(passwordProvider: { "pwd" }), session: makeSession())
    #expect(try await client.myMeat() == 42)
}
}
