extension Wildable where Self: CaseIterable {
    public static var allValues: AnySequence<Self> {
        AnySequence(Self.allCases)
    }
}

// syntactic sugar: can conform to this one protocol instead of two
public protocol WildcardEnum: CaseIterable, Wildable {}
