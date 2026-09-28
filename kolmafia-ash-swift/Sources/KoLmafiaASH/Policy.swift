import Foundation

public typealias ASHCallPolicy = @Sendable (_ function: String, _ args: [JSONValue]) throws -> Void

public enum ASHPolicies {
    public static let allowAll: ASHCallPolicy = { _, _ in }

    public static func deny(_ names: Set<String>) -> ASHCallPolicy {
        { function, _ in
            guard !names.contains(function) else {
                throw ASHError.policyDenied(function: function)
            }
        }
    }

    public static func deny(_ names: String...) -> ASHCallPolicy {
        deny(Set(names))
    }

    public static func allowOnly(_ names: Set<String>) -> ASHCallPolicy {
        { function, _ in
            guard names.contains(function) else {
                throw ASHError.policyDenied(function: function)
            }
        }
    }

    public static func allowOnly(_ names: String...) -> ASHCallPolicy {
        allowOnly(Set(names))
    }
}
