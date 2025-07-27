public protocol WildcardPrototyping {
    init()
}

extension WildcardPrototyping {

    public static func variants(
        _ wildcardPaths: WildcardPath<Self>...
    ) -> [Self] {
        TestingWildcards.invariantCombinations(.init(), wildcardPaths: wildcardPaths)
    }

    public static func variants(
        _ wildcardPaths: [WildcardPath<Self>]
    ) -> [Self] {
        TestingWildcards.invariantCombinations(.init(), wildcardPaths: wildcardPaths)
    }

    // for if you want to pass all variants as one into the test (as a list)
    public static func variantsList(
        _ wildcardPaths: WildcardPath<Self>...
    ) -> [[Self]] {
        [TestingWildcards.invariantCombinations(.init(), wildcardPaths: wildcardPaths)]
    }
}
