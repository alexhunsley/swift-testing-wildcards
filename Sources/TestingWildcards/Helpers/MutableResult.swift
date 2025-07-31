/// Mutable helper for Result<Succcess, Failure>.
/// You can retrieve the real Result instance via the `mutableResult.result` property.
public struct MutableResult<Success, Failure: Error>: Equatable where Success: Equatable, Failure: Equatable {
    private(set) var result: Result<Success, Failure>? = nil

    public var success: Success {
        get { fatalError("Calling getter on MutableResult `success` is not allowed") }
        set {
            precondition(result == nil, "MutableResult already contains a value")
            result = .success(newValue)
        }
    }
    public var failure: Failure {
        get { fatalError("Calling getter on MutableResult `failure` is not allowed") }
        set {
            precondition(result == nil, "MutableResult already contains a value")
            result = .failure(newValue)
        }
    }
}

extension MutableResult: InvariantValues where Success: InvariantValues, Failure: InvariantValues {
    public static var allValues: AnySequence<MutableResult<Success, Failure>> {
        let successVariants = Success.allValues.map {
            MutableResult(result: .success($0))
        }

        let failureVariants = Failure.allValues.map {
            MutableResult(result: .failure($0))
        }

        return AnySequence(successVariants + failureVariants)
    }
}
