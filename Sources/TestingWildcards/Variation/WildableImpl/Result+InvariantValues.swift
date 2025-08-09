extension Result: Wildable where Success: Wildable & Equatable, Failure: Wildable & Equatable {
    public static var allValues: AnySequence<Result<Success, Failure>> {
        let successVariants = Success.allValues.map { successAllValues in Result { successAllValues } }

        let failureVariants = Failure.allValues.map { failureAllValues in
            .failure(failureAllValues) as Result<Success, Failure>
        }

        return AnySequence(successVariants + failureVariants)
    }
}
