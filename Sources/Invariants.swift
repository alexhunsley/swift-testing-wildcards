public protocol InvariantValues {
    static var allValues: [Self] { get }
}

extension Bool: InvariantValues {
    public static let allValues = [true, false]
}

extension InvariantValues where Self: CaseIterable {
    public static var allValues: [Self] { Array(Self.allCases) }
}

extension Optional: InvariantValues where Wrapped: InvariantValues {
    public static var allValues: [Optional<Wrapped>] {
        [nil] + Wrapped.allValues.map(Optional.some)
    }
}

// Void can't conform to InvariantValues because of how tuples work in swift
//extension Void: InvariantValues {
//    public static var allValues: [Void] { [()] }
//}

// Results aren't mutable. So we can't use our mutation of a prototype idea.
// instead, we could impl the allInvariantCombinations for Result return type specifically,
// but that wouldn't play nicely if e.g. the Result was a field of a struct we were
// wildcarding on, etc.
//extension Result: InvariantValues where Success: InvariantValues, Failure: InvariantValues {
//    public static var allValues: [Result<Success, Failure>] {
//        Success.allValues.map(Result.success) +
//        Failure.allValues.map(Result.failure)
//    }
//}

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

///
///

public protocol InvariantHolder { }

// extension for conforming objects, so can call like:
//   myProto.allInvariantCombinations
//extension InvariantValues {
//
// (we don't add this to InvariantValues proto because then the
// proto type would have to provide allValues, which doesn't always make sense)
extension InvariantHolder {
    public func allInvariantCombinations(
        wildcardPaths: [WildcardPath<Self>] = []
    ) -> [Self] {
        TestingWildcards.allInvariantCombinations(self, wildcardPaths: wildcardPaths)
    }
}
