public struct MutableResult<Success, Failure: Error> {
    /// Holds a success value if set
    var success: Success?

    /// Holds a failure value if set
    var failure: Failure?

    /// Initializes as empty (neither success nor failure set)
    init(success: Success? = nil, failure: Failure? = nil) {
        self.success = success
        self.failure = failure
    }

    /// Returns a standard Result, if one is representable
    var result: Result<Success, Failure>? {
        switch (success, failure) {
        case let (success?, nil):
            return .success(success)
        case let (nil, failure?):
            return .failure(failure)
        default:
            return nil // Ambiguous or empty
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
