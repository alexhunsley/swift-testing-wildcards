extension Result: InvariantValues where Success: InvariantValues & Equatable, Failure: InvariantValues & Equatable {
    public static var allValues: AnySequence<Result<Success, Failure>> {
        let successVariants = Success.allValues.map { x in
            Result { x }
        }

        let failureVariants = Failure.allValues.map { x in
            .failure(x) as Result<Success, Failure>
        }

        return AnySequence(successVariants + failureVariants)
    }
}
