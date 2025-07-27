extension InvariantValues where Self: CaseIterable {
    public static var allValues: AnySequence<Self> {
        AnySequence(Self.allCases)
    }
}

