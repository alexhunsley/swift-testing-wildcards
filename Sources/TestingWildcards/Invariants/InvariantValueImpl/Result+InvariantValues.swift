extension Result: InvariantValues where Success: InvariantValues & Equatable, Failure: InvariantValues & Equatable {
    public static var allValues: AnySequence<Result<Success, Failure>> {
        let successVariants = Success.allValues.map { successAllValues in Result { successAllValues } }

        let failureVariants = Failure.allValues.map { failureAllValues in
            .failure(failureAllValues) as Result<Success, Failure>
        }

        return AnySequence(successVariants + failureVariants)
    }
}

/// the allValues for Never is just an empty list -- i.e. the  identiity, because algebraicly it multiples combinations by 1
extension Never: InvariantValues {
    public static var allValues: AnySequence<Never> {
        AnySequence(EmptyCollection<Never>())
    }
}

/// A nominal stand-in for Void (no value), for use in e.g. `Result<empty, Error>`
public struct Empty: Equatable, Sendable { }
// access to the one instance of empty
public let empty = Empty()

extension Empty: InvariantValues {
    public static var allValues: AnySequence<Empty> {
        return AnySequence([empty])
    }
}
