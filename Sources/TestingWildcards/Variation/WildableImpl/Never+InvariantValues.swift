extension Never: Wildable {
    public static var allValues: AnySequence<Never> {
        // Never cannot be instantiated
        .init(EmptyCollection())
    }
}
