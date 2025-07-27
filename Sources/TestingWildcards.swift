import Foundation

public enum WildcardPath<Root> {
    case wild(_ path: VariantKeyPath<Root>)
    case values(_ path: VariantKeyPath<Root>)

    public static func wild<V: InvariantValues>(_ keyPath: WritableKeyPath<Root, V>) -> Self {
        .wild(VariantKeyPath(keyPath))
    }

    public static func values<V: Hashable, S: Sequence>(_ keyPath: WritableKeyPath<Root, V>, _ values: S) -> Self where S.Element == V {
        let sequence = AnySequence(values)
        return .values(VariantKeyPath(keyPath, values: sequence))
    }

    // a single value
    public static func values<V: Hashable>(
        _ keyPath: WritableKeyPath<Root, V>,
        _ value: V
    ) -> Self {
        let sequence = AnySequence([value])
        return .values(VariantKeyPath(keyPath, values: sequence))
    }
}

public struct VariantKeyPath<Root> {
    public let keyPath: PartialKeyPath<Root>
    public let set: (inout Root, Any) -> Void
    public let values: AnySequence<Any>

    /// From an explicit sequence of values
    public init<Value, S: Sequence>(
        _ keyPath: WritableKeyPath<Root, Value>,
        values: S
    ) where S.Element == Value {
        self.keyPath = keyPath
        self.set = { root, value in
            root[keyPath: keyPath] = value as! Value
        }
        self.values = AnySequence(values.map { $0 as Any })
    }

    /// From a type conforming to `InvariantValues`
    public init<Value: InvariantValues>(
        _ keyPath: WritableKeyPath<Root, Value>
    ) {
        self.keyPath = keyPath
        self.set = { root, value in
            root[keyPath: keyPath] = value as! Value
        }
        self.values = AnySequence(Value.allValues.map { $0 as Any })
    }
}

func invariantCombinations<T>(
    _ base: T,
    wildcardPaths: [WildcardPath<T>] = []
) -> [T] {

    // Collect keyPath/set/values as sequences
    let combined: [(keyPath: PartialKeyPath<T>, set: (inout T, Any) -> Void, values: AnySequence<Any>)] =
        wildcardPaths.map { wildcardPath in
            switch wildcardPath {
            case let .wild(path):
                return (path.keyPath, path.set, AnySequence(path.values))
            case let .values(path):
                return (path.keyPath, path.set, path.values)
            }
        }

    // Convert sequences to arrays for cartesian product
    let allValueSets: [[Any]] = combined.map { Array($0.values) }

    // Cartesian product
    func product(_ sets: [[Any]]) -> [[Any]] {
        sets.reduce([[]]) { acc, values in
            acc.flatMap { prefix in values.map { prefix + [$0] } }
        }
    }

    // Construct output objects from value combinations
    return product(allValueSets).map { values in
        var copy = base
        for (i, value) in values.enumerated() {
            combined[i].set(&copy, value)
        }
        return copy
    }
}
