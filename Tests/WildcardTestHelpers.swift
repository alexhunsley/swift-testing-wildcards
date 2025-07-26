@testable import TestingWildcards

public enum Mode: CaseIterable, InvariantValues, CustomStringConvertible {
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
    public static var wildcardPrototype: Self {
        .init(name: "bob", flag: true, mode: .alpha, count: 0)
    }

    public var name: String
    public var flag: Bool
    public var mode: Mode
    public var count: Int

    public var description: String {
        "[Example name: \(name) flag: \(flag), mode: \(mode), count: \(count)])"
    }
}

enum SomeError: Error, CaseIterable {
    case catWokeUp
    case dogGotRainedOn
}
