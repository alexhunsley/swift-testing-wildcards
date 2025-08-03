public protocol WildcardPrototyping: Equatable {
    init()
}

public extension WildcardPrototyping {
    func variants(
        _ wildcardPaths: WildcardPath<Self>...
    ) -> [Self] {
        invariantCombinations(self, wildcardPaths: wildcardPaths)
    }

    static func variants(
        _ wildcardPaths: WildcardPath<Self>...
    ) -> [Self] {
        invariantCombinations(Self(), wildcardPaths: wildcardPaths)
    }

    static func variants(
        _ wildcardPaths: [WildcardPath<Self>]
    ) -> [Self] {
        invariantCombinations(Self(), wildcardPaths: wildcardPaths)
    }

    /// for retrieving all variants as a (single item) list of lists; particularly useful
    /// if you want to pass a single list of variants into a @Test func.
    static func variantsList(
        _ wildcardPaths: WildcardPath<Self>...
    ) -> [[Self]] {
        [invariantCombinations(Self(), wildcardPaths: wildcardPaths)]
    }
}
