public struct MutableResult<Success, Failure: Error>: Equatable where Success: Equatable, Failure: Equatable {
    public var success: Success?

    public var failure: Failure?

    public  init(success: Success? = nil, failure: Failure? = nil) {
        precondition(success == nil || failure == nil, "Cannot initialize with both success and failure")
        self.success = success
        self.failure = failure
    }

    public var result: Result<Success, Failure>? {
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

extension MutableResult {
    public func get() throws -> Success {
        switch (success, failure) {
        case let (success?, nil):
            return success
        case let (nil, failure?):
            throw failure
        case (nil, nil):
            preconditionFailure("MutableResult.get(): neither success nor failure is set")
        case (_?, _?):
            preconditionFailure("MutableResult.get(): both success and failure are set — ambiguous")
        }
    }
}
