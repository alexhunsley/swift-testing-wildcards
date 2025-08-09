public protocol WildableOptionSet: Wildable, OptionSet where RawValue: FixedWidthInteger {
    static var allOptions: [Self] { get }
}

extension WildableOptionSet {
    public static var allValues: AnySequence<Self> {
        let all = allOptions.reduce(Self()) { $0.union($1) }
        let max = all.rawValue
        return AnySequence((0...max).compactMap { Self(rawValue: $0) })
    }
}
