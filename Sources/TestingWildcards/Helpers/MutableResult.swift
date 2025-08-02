/// Mutable helper for Result<Succcess, Failure>.
/// You can retrieve the real `Result` instance via the `result` property.
public struct MutableResult<Success, Failure: Error>: Equatable where Success: Equatable, Failure: Equatable {
    private(set) var result: Result<Success, Failure>? = nil

    public init() { }

    public init(result: Result<Success, Failure>) {
        self.result = result
    }

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

//extension MutableResult: InvariantValues where Success: InvariantValues, Failure: InvariantValues {
//    public static var allValues: AnySequence<MutableResult<Success, Failure>> {
//        let successVariants = Success.allValues.map {
//            MutableResult(result: .success($0))
//        }
//
//        let failureVariants = Failure.allValues.map {
//            MutableResult(result: .failure($0))
//        }
//
//        return AnySequence(successVariants + failureVariants)
//    }
//}

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
