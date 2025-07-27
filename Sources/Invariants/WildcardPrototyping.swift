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

    // for if you want to pass all variants as one into the test (as a list)
    public static func variantsList(
        _ wildcardPaths: WildcardPath<Self>...
    ) -> [[Self]] {
        [TestingWildcards.allInvariantCombinations(Self.prototype, wildcardPaths: wildcardPaths)]
    }
}
