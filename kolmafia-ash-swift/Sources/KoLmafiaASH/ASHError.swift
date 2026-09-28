import Foundation

public enum ASHError: Error, Sendable, Equatable, CustomStringConvertible {
    case invalidBaseURL(String)
    case passwordProvider(String)
    case transport(String)
    case httpStatus(Int, String)
    case api(String)
    case malformedResponse(String)
    case policyDenied(function: String)
    case typeMismatch(context: String, expected: String, actual: JSONValue)

    public var description: String {
        switch self {
        case .invalidBaseURL(let value): return "Invalid KoLmafia base URL: \(value)"
        case .passwordProvider(let value): return "Password provider failed: \(value)"
        case .transport(let value): return "Transport error: \(value)"
        case .httpStatus(let status, let body): return "KoLmafia HTTP \(status): \(body)"
        case .api(let value): return "KoLmafia JSON API error: \(value)"
        case .malformedResponse(let value): return "Malformed KoLmafia response: \(value)"
        case .policyDenied(let function): return "ASH call denied by policy: \(function)"
        case .typeMismatch(let context, let expected, let actual): return "Type mismatch for \(context): expected \(expected), got \(actual)"
        }
    }
}
