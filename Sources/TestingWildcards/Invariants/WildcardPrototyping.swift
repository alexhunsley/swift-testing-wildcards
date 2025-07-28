public protocol WildcardPrototyping {
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

    // for if you want to pass all variants as one into the test (as a list)
    static func variantsList(
        _ wildcardPaths: WildcardPath<Self>...
    ) -> [[Self]] {
        [invariantCombinations(Self(), wildcardPaths: wildcardPaths)]
    }
}
