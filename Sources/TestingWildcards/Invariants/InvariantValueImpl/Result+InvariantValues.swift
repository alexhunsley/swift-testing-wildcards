extension Result: InvariantValues where Success: InvariantValues & Equatable, Failure: InvariantValues & Equatable {
    public static var allValues: AnySequence<Result<Success, Failure>> {
        let successVariants = Success.allValues.map { successAllValues in Result { successAllValues } }

        let failureVariants = Failure.allValues.map { failureAllValues in
            .failure(failureAllValues) as Result<Success, Failure>
        }

        return AnySequence(successVariants + failureVariants)
    }
}
