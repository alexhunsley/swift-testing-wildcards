@testable import TestingWildcards

// could I make my own protocol based on CaseIterable but which adds iterable over
// associated types that are CaseIterable?
public enum Mode: CaseIterable, InvariantValues, CustomStringConvertible {
//    case alpha, beta, gamma(Bool)
    case alpha, beta, gamma

    public var description: String {
        switch self {
        case .alpha: return "Alpha"
        case .beta: return "Beta"
        case .gamma: return "Gamma"
        }
    }
}

public struct Example: WildcardPrototyping, CustomStringConvertible {
    public static var prototype: Self {
        .init(name: "bob", flag: true, mode: .alpha, count: 0, error: nil)
    }

    public var name: String
    public var flag: Bool
    public var mode: Mode
    public var count: Int
    public var error: SomeError?

    public var description: String {
        "[Example name: \(name) flag: \(flag), mode: \(mode), count: \(count), error: \(String(describing: error))])"
    }

//    public static func callAsFunction(_ wildcardPaths: [WildcardPath<Self>]) -> [Self] {
//        TestingWildcards.allInvariantCombinations(Self.prototype, wildcardPaths: wildcardPaths)
//    }

}

public enum SomeError: Error, InvariantValues, CaseIterable {
    case catWokeUp
    case dogGotRainedOn
}
