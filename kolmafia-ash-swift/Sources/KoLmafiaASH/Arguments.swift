import Foundation

public protocol ASHArgumentConvertible: Sendable {
    var ashJSONValue: JSONValue { get }
}

extension JSONValue: ASHArgumentConvertible {
    public var ashJSONValue: JSONValue { self }
}

extension String: ASHArgumentConvertible {
    public var ashJSONValue: JSONValue { .string(self) }
}

extension Int: ASHArgumentConvertible {
    public var ashJSONValue: JSONValue { .integer(self) }
}

extension Double: ASHArgumentConvertible {
    public var ashJSONValue: JSONValue { .number(self) }
}

extension Bool: ASHArgumentConvertible {
    public var ashJSONValue: JSONValue { .bool(self) }
}

public struct ASHNull: ASHArgumentConvertible, Sendable {
    public init() {}
    public var ashJSONValue: JSONValue { .null }
}

public enum ASHIdentifier: Sendable, Hashable {
    case string(String)
    case number(Int)
}

public protocol ASHEnumerated: ASHArgumentConvertible, Sendable, Hashable {
    static var objectType: String { get }
    var identifier: ASHIdentifier { get }
}

extension ASHEnumerated {
    public var ashJSONValue: JSONValue {
        var object: [String: JSONValue] = ["objectType": .string(Self.objectType)]
        switch identifier {
        case .string(let value): object["identifierString"] = .string(value)
        case .number(let value): object["identifierNumber"] = .integer(value)
        }
        return .object(object)
    }
}

public struct ASHEnumRef: ASHArgumentConvertible, Sendable, Hashable {
    public let objectType: String
    public let identifier: ASHIdentifier

    public init(_ objectType: String, _ name: String) {
        self.objectType = objectType
        self.identifier = .string(name)
    }

    public init(_ objectType: String, id: Int) {
        self.objectType = objectType
        self.identifier = .number(id)
    }

    public var ashJSONValue: JSONValue {
        var object: [String: JSONValue] = ["objectType": .string(objectType)]
        switch identifier {
        case .string(let value): object["identifierString"] = .string(value)
        case .number(let value): object["identifierNumber"] = .integer(value)
        }
        return .object(object)
    }
}

// KoLmafia ASH enumerated value wrappers.
public struct Item: ASHEnumerated { public static let objectType = "Item"; public let identifier: ASHIdentifier; public init(_ name: String) { identifier = .string(name) }; public init(id: Int) { identifier = .number(id) } }
public struct Familiar: ASHEnumerated { public static let objectType = "Familiar"; public let identifier: ASHIdentifier; public init(_ name: String) { identifier = .string(name) }; public init(id: Int) { identifier = .number(id) } }
public struct Skill: ASHEnumerated { public static let objectType = "Skill"; public let identifier: ASHIdentifier; public init(_ name: String) { identifier = .string(name) }; public init(id: Int) { identifier = .number(id) } }
public struct Effect: ASHEnumerated { public static let objectType = "Effect"; public let identifier: ASHIdentifier; public init(_ name: String) { identifier = .string(name) }; public init(id: Int) { identifier = .number(id) } }
public struct Monster: ASHEnumerated { public static let objectType = "Monster"; public let identifier: ASHIdentifier; public init(_ name: String) { identifier = .string(name) }; public init(id: Int) { identifier = .number(id) } }
public struct Location: ASHEnumerated { public static let objectType = "Location"; public let identifier: ASHIdentifier; public init(_ name: String) { identifier = .string(name) }; public init(id: Int) { identifier = .number(id) } }
public struct Slot: ASHEnumerated { public static let objectType = "Slot"; public let identifier: ASHIdentifier; public init(_ name: String) { identifier = .string(name) }; public init(id: Int) { identifier = .number(id) } }
public struct Stat: ASHEnumerated { public static let objectType = "Stat"; public let identifier: ASHIdentifier; public init(_ name: String) { identifier = .string(name) }; public init(id: Int) { identifier = .number(id) } }
public struct Path: ASHEnumerated { public static let objectType = "Path"; public let identifier: ASHIdentifier; public init(_ name: String) { identifier = .string(name) }; public init(id: Int) { identifier = .number(id) } }
public struct AscensionClass: ASHEnumerated { public static let objectType = "Class"; public let identifier: ASHIdentifier; public init(_ name: String) { identifier = .string(name) }; public init(id: Int) { identifier = .number(id) } }
public struct Element: ASHEnumerated { public static let objectType = "Element"; public let identifier: ASHIdentifier; public init(_ name: String) { identifier = .string(name) }; public init(id: Int) { identifier = .number(id) } }
public struct Phylum: ASHEnumerated { public static let objectType = "Phylum"; public let identifier: ASHIdentifier; public init(_ name: String) { identifier = .string(name) }; public init(id: Int) { identifier = .number(id) } }
public struct Thrall: ASHEnumerated { public static let objectType = "Thrall"; public let identifier: ASHIdentifier; public init(_ name: String) { identifier = .string(name) }; public init(id: Int) { identifier = .number(id) } }
public struct Servant: ASHEnumerated { public static let objectType = "Servant"; public let identifier: ASHIdentifier; public init(_ name: String) { identifier = .string(name) }; public init(id: Int) { identifier = .number(id) } }
public struct Coinmaster: ASHEnumerated { public static let objectType = "Coinmaster"; public let identifier: ASHIdentifier; public init(_ name: String) { identifier = .string(name) }; public init(id: Int) { identifier = .number(id) } }
