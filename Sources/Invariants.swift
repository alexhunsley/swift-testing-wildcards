// thoughts:
//
// * one potential issue is that we mutate the prototype, so you need a mutable object.
//   but the code you're testing might well take an immutable type.
//
//   But this tool is meant for driving Testing test cases, where you will
//   probably construct the real type from it; so I think this mutable aspect is ok.

public protocol InvariantValues {
    static var allValues: AnySequence<Self> { get }
}

extension Bool: InvariantValues {
    public static var allValues: AnySequence<Self> {
        AnySequence([true, false])
    }
}

extension InvariantValues where Self: CaseIterable {
    public static var allValues: AnySequence<Self> {
        AnySequence(Self.allCases)
    }
}

extension Optional: InvariantValues where Wrapped: InvariantValues {
    public static var allValues: AnySequence<Optional<Wrapped>> {
        AnySequence([nil] + Wrapped.allValues.map(Optional.some))
    }
}

public protocol InvariantOptionSet: InvariantValues, OptionSet where RawValue: FixedWidthInteger {
    static var allOptions: [Self] { get }
}

extension InvariantOptionSet {
    public static var allValues: AnySequence<Self> {
        let all = allOptions.reduce(Self()) { $0.union($1) }
        let max = all.rawValue
        return AnySequence((0...max).compactMap { Self(rawValue: $0) })
    }
}

public protocol WildcardPrototyping {
    static var prototype: Self { get }
}

// (we don't add this to InvariantValues proto because then the
// proto type would have to provide allValues, which doesn't always make sense)
extension WildcardPrototyping {
    public static func variants(
        _ wildcardPaths: WildcardPath<Self>...
    ) -> [Self] {
        TestingWildcards.allInvariantCombinations(Self.prototype, wildcardPaths: wildcardPaths)
    }

    public static func variants(
        _ wildcardPaths: [WildcardPath<Self>]
    ) -> [Self] {
        TestingWildcards.allInvariantCombinations(Self.prototype, wildcardPaths: wildcardPaths)
    }
}
