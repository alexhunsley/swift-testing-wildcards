extension Bool: Wildable {
    public static var allValues: AnySequence<Self> {
        AnySequence([true, false])
    }
}
