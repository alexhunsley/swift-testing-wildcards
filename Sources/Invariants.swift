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
