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

// we could provide a thing for e.g. ints that provides some random values in the range (or in custom range).

extension OptionSet where Self: InvariantValues, Self.RawValue: FixedWidthInteger {
    public static var allValues: [Self] {
        let allBits = allBitsSet().rawValue
        return (0...allBits).compactMap { Self(rawValue: $0) }
    }

    /// Derive the max mask from combining all known options
    private static func allBitsSet() -> Self {
        allOptions.reduce(Self()) { $0.union($1) }
    }

    /// Should be implemented per type
    public static var allOptions: [Self] {
        fatalError("Override allOptions in \(Self.self)")
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
