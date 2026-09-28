import Foundation

public struct ASHFunctionCall: Sendable, Equatable, Encodable {
    public let name: String
    public let args: [JSONValue]

    public init(name: String, args: [JSONValue] = []) {
        self.name = name
        self.args = args
    }

    public init(_ name: String, _ args: any ASHArgumentConvertible...) {
        self.name = name
        self.args = args.map(\.ashJSONValue)
    }
}

public struct ASHBatchRequest: Sendable, Equatable {
    public var properties: [String]
    public var functions: [ASHFunctionCall]

    public init(properties: [String] = [], functions: [ASHFunctionCall] = []) {
        self.properties = properties
        self.functions = functions
    }
}

public struct ASHBatchResponse: Sendable, Equatable {
    public let properties: [JSONValue]
    public let functions: [JSONValue]
}

struct WireRequest: Encodable {
    let properties: [String]?
    let functions: [ASHFunctionCall]?
}

struct WireResponse: Decodable {
    let error: String?
    let properties: [JSONValue]?
    let functions: [JSONValue]?
}
