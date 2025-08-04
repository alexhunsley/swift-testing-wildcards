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

// can't! Void is non-nominal.
//extension Void: InvariantValues {
//
//}

// distinction:
//
// Void is non-nominal tuple '()' for 'no return type' (but this result CAN return, just nothing).
// Never means it can't return, because `enum Never { }` is not instantiable.
//


/// A nominal stand-in for Void (no value)
public struct Empty: Equatable, Sendable { }
public let empty = Empty()

extension Empty: InvariantValues {
    public static var allValues: AnySequence<Empty> {
        // there’s exactly one inhabitant of Unit,
        // so we return a sequence containing a single .init()
        return AnySequence([empty])
    }
}
