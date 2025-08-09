extension Optional: Wildable where Wrapped: Wildable {
    public static var allValues: AnySequence<Optional<Wrapped>> {
        AnySequence([nil] + Wrapped.allValues.map(Optional.some))
    }
}
