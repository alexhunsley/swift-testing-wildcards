// thoughts:
//
// * one potential issue is that we mutate the prototype, so you need a mutable object.
//   but the code you're testing might well take an immutable type.
//
//   But this tool is meant for driving Testing test cases, where you will
//   probably construct the real type from it; so I think this mutable aspect is ok.

public protocol InvariantValues {
//    associatedtype AllValues: Sequence where AllValues.Element == Self
//    static var allValues: AllValues { get }

    static var allValues: AnySequence<Self> { get }}

extension Bool: InvariantValues {
    public static var allValues: AnySequence<Self> {
        AnySequence([true, false])
    }
//    public static let allValues = AnySequence([Bool.yes, Bool.no])
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

public protocol WildcardPrototyping {
    static var prototype: Self { get }
//    init()
}

// extension for conforming objects, so can call like:
//   myProto.allInvariantCombinations
//extension InvariantValues {
//
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
//        removing: ((Self) -> Bool)? = nil
    ) -> [Self] {
        TestingWildcards.allInvariantCombinations(Self.prototype, wildcardPaths: wildcardPaths)
//        let variants = TestingWildcards.allInvariantCombinations(Self.prototype, wildcardPaths: wildcardPaths)
//        guard let removing else {
//            return variants
//        }
//        return variants.filter(not(removing))
    }

    // doesn't work! Compiler can't handle the Example( ... wilds) form at call site. It's
    // not the clearest, to be fair.
//    public static func callAsFunction(_ wildcardPaths: WildcardPath<Self>...) -> [Self] {
//        TestingWildcards.allInvariantCombinations(Self.prototype, wildcardPaths: wildcardPaths)
//    }    
}

//func not<T>(_ predicate: @escaping (T) -> Bool) -> (T) -> Bool {
//    { !predicate($0) }
//}

extension Sequence {
    /// Returns a new sequence with the elements that do *not* match the given predicate.
    func remove(_ predicate: (Element) throws -> Bool) rethrows -> [Element] {
        try self.filter { try !predicate($0) }
    }
}
