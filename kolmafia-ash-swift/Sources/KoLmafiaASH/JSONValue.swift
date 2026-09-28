import Foundation

/// A Sendable, Codable JSON value used for ASH arguments and results.
public enum JSONValue: Sendable, Equatable, Codable {
    case null
    case bool(Bool)
    case integer(Int)
    case number(Double)
    case string(String)
    case array([JSONValue])
    case object([String: JSONValue])

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() { self = .null; return }
        if let value = try? container.decode(Bool.self) { self = .bool(value); return }
        if let value = try? container.decode(Int.self) { self = .integer(value); return }
        if let value = try? container.decode(Double.self) { self = .number(value); return }
        if let value = try? container.decode(String.self) { self = .string(value); return }
        if let value = try? container.decode([JSONValue].self) { self = .array(value); return }
        if let value = try? container.decode([String: JSONValue].self) { self = .object(value); return }
        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unsupported JSON value")
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .null: try container.encodeNil()
        case .bool(let value): try container.encode(value)
        case .integer(let value): try container.encode(value)
        case .number(let value): try container.encode(value)
        case .string(let value): try container.encode(value)
        case .array(let value): try container.encode(value)
        case .object(let value): try container.encode(value)
        }
    }

    public var stringValue: String? {
        guard case .string(let value) = self else { return nil }
        return value
    }

    public var intValue: Int? {
        switch self {
        case .integer(let value): return value
        case .number(let value) where value.rounded() == value: return Int(value)
        default: return nil
        }
    }

    public var doubleValue: Double? {
        switch self {
        case .integer(let value): return Double(value)
        case .number(let value): return value
        default: return nil
        }
    }

    public var boolValue: Bool? {
        guard case .bool(let value) = self else { return nil }
        return value
    }

    public func requireString(_ context: String = "value") throws -> String {
        guard let value = stringValue else { throw ASHError.typeMismatch(context: context, expected: "String", actual: self) }
        return value
    }

    public func requireInt(_ context: String = "value") throws -> Int {
        guard let value = intValue else { throw ASHError.typeMismatch(context: context, expected: "Int", actual: self) }
        return value
    }

    public func requireDouble(_ context: String = "value") throws -> Double {
        guard let value = doubleValue else { throw ASHError.typeMismatch(context: context, expected: "Double", actual: self) }
        return value
    }

    public func requireBool(_ context: String = "value") throws -> Bool {
        guard let value = boolValue else { throw ASHError.typeMismatch(context: context, expected: "Bool", actual: self) }
        return value
    }
}

extension JSONValue: CustomStringConvertible {
    public var description: String {
        switch self {
        case .null: return "null"
        case .bool(let value): return String(value)
        case .integer(let value): return String(value)
        case .number(let value): return String(value)
        case .string(let value): return value
        case .array(let values): return "[" + values.map(\.description).joined(separator: ", ") + "]"
        case .object(let values):
            return "{" + values.keys.sorted().map { "\($0): \(values[$0]!)" }.joined(separator: ", ") + "}"
        }
    }
}
