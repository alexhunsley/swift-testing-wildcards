import Foundation

public enum WildcardPath<Root> {
    case wild(_ path: AnyWritableKeyPath<Root>)
    case values(_ path: OverriddenKeyPath<Root>)

    public static func wild<V: InvariantValues>(_ keyPath: WritableKeyPath<Root, V>) -> Self {
        .wild(AnyWritableKeyPath(keyPath))
    }

    public static func values<V: Hashable, S: Sequence>(_ keyPath: WritableKeyPath<Root, V>, _ values: S) -> Self where S.Element == V {
        let sequence = AnySequence(values)
        return .values(OverriddenKeyPath(keyPath, values: sequence))
    }

    // a single value
    public static func values<V: Hashable>(
        _ keyPath: WritableKeyPath<Root, V>,
        _ value: V
    ) -> Self {
        let sequence = AnySequence([value])
        return .values(OverriddenKeyPath(keyPath, values: sequence))
    }
}

// could these two be merged?
public struct AnyWritableKeyPath<Root> {
    public let keyPath: PartialKeyPath<Root>
    public let set: (inout Root, Any) -> Void
    public let getAllValues: () -> [Any]

    public init<Value: InvariantValues>(_ keyPath: WritableKeyPath<Root, Value>) {
        self.keyPath = keyPath
        self.set = { root, value in
            root[keyPath: keyPath] = value as! Value
        }
        self.getAllValues = {
            Array(Value.allValues).map { $0 as Any }
        }
    }
}

public struct OverriddenKeyPath<Root> {
    public let keyPath: PartialKeyPath<Root>
    public let set: (inout Root, Any) -> Void
    public let values: AnySequence<Any>

    public init<Value, S: Sequence>(
        _ path: WritableKeyPath<Root, Value>,
        values: S
    ) where S.Element == Value {
        self.keyPath = path
        self.set = { root, value in
            root[keyPath: path] = value as! Value
        }
        self.values = AnySequence(values.map { $0 as Any })
    }
}

//extension AnyObject<T> where T: InvariantValues {
//}

// should this be module only? And always must use Type.staticThing to access?
func allInvariantCombinations<T>(
    _ base: T,
    wildcardPaths: [WildcardPath<T>] = []
) -> [T] {

    let combined: [(keyPath: PartialKeyPath<T>, set: (inout T, Any) -> Void, values: [Any])] =
        wildcardPaths.map { wildcardPath in
            switch wildcardPath {
            case let .wild(writablePath):
                return (writablePath.keyPath, writablePath.set, writablePath.getAllValues())
            case let .values(overridenPath):
                return (
                    overridenPath.keyPath,
                    overridenPath.set,
                    Array(overridenPath.values)
                )
            }
        }

    // Cartesian product of values (to generate all combos)
    func product(_ sets: [[Any]]) -> [[Any]] {
        sets.reduce([[]]) { acc, values in
            acc.flatMap { prefix in values.map { prefix + [$0] } }
        }
    }

    let allValueSets = combined.map { $0.values }

    return product(allValueSets).map { values in
        var copy = base
        for (i, value) in values.enumerated() {
            let setter = combined[i].set
            setter(&copy, value)
        }
        return copy
    }
}
