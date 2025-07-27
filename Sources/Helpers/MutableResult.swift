public struct MutableResult<Success, Failure: Error>: Equatable where Success: Equatable, Failure: Equatable {
    var success: Success?

    var failure: Failure?

    init(success: Success? = nil, failure: Failure? = nil) {
        self.success = success
        self.failure = failure
    }

    var result: Result<Success, Failure>? {
        switch (success, failure) {
        case let (success?, nil):
            return .success(success)
        case let (nil, failure?):
            return .failure(failure)
        default:
            // Ambiguous or empty
            return nil
        }
    }
}

extension MutableResult: InvariantValues where Success: InvariantValues, Failure: InvariantValues {
    public static var allValues: AnySequence<MutableResult<Success, Failure>> {
        let successVariants = Success.allValues.map {
            MutableResult(success: $0, failure: nil)
        }

        let failureVariants = Failure.allValues.map {
            MutableResult(success: nil, failure: $0)
        }

        return AnySequence(successVariants + failureVariants)
    }
}
