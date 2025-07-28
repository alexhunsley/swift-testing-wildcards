extension Optional: InvariantValues where Wrapped: InvariantValues {
    public static var allValues: AnySequence<Optional<Wrapped>> {
        AnySequence([nil] + Wrapped.allValues.map(Optional.some))
    }
}
