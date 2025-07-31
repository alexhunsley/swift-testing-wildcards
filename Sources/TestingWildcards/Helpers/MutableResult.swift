/// Mutable helper for Result<Succcess, Failure>.
/// You can retrieve a real Result instance via the `mutableResult.result` property.
public struct MutableResult<Success, Failure: Error>: Equatable where Success: Equatable, Failure: Equatable {
    public var success: Success? = nil
    public var failure: Failure? = nil

    public var result: Result<Success, Failure>? {
        if let success {
            return .success(success)
        }
        if let failure {
            return .failure(failure)
        }
        return nil
    }
}

extension MutableResult: InvariantValues where Success: InvariantValues, Failure: InvariantValues {
    public static var allValues: AnySequence<MutableResult<Success, Failure>> {
        let successVariants = Success.allValues.map {
            MutableResult(success: $0)
        }

        let failureVariants = Failure.allValues.map {
            MutableResult(failure: $0)
        }

        return AnySequence(successVariants + failureVariants)
    }
}

extension MutableResult {
    public func get() throws -> Success {
        if let success {
            return success
        }
        if let failure {
            throw failure
        }
        preconditionFailure("MutableResult.get(): success and failure are both nil")
    }
}
