extension Bool: InvariantValues {
    public static var allValues: AnySequence<Self> {
        AnySequence([true, false])
    }
}
