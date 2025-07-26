import Foundation

//public enum WildcardPath<Root2> {
//    case simple(_ path: AnyWritableKeyPath<Root2>)
//    case manual(_ path: OverriddenKeyPath<Root2>)
//
//    public static func simple(_ keyPath: WritableKeyPath<Root2, some InvariantValues>) -> Self {
//        .simple(AnyWritableKeyPath(keyPath))
//    }
//
//    public static func manual<V>(_ keyPath: WritableKeyPath<Root2, V>, values: [V]) -> Self {
//        .manual(OverriddenKeyPath(keyPath, values: values))
//    }
//}

public enum WildcardPath<Root2> {
    case auto(_ path: AnyWritableKeyPath<Root2>)
    case options(_ path: OverriddenKeyPath<Root2>)

    public static func simple<V: InvariantValues>(_ keyPath: WritableKeyPath<Root2, V>) -> Self {
        .auto(AnyWritableKeyPath(keyPath))
    }

    public static func manual<V: Hashable>(_ keyPath: WritableKeyPath<Root2, V>, values: [V]) -> Self {
        .options(OverriddenKeyPath(keyPath, values: values))
    }
}


public struct AnyWritableKeyPath<Root> {
    public let keyPath: PartialKeyPath<Root>
    public let set: (inout Root, Any) -> Void
    public let getAllValues: () -> [Any]

    public init<Value: InvariantValues>(_ keyPath: WritableKeyPath<Root, Value>) {
        self.keyPath = keyPath
        self.set = { root, value in
            root[keyPath: keyPath] = value as! Value
        }
        self.getAllValues = { Value.allValues }
    }
}

public struct OverriddenKeyPath<Root> {
    public let keyPath: PartialKeyPath<Root>
    public let set: (inout Root, Any) -> Void
    public let values: [Any]

    public init<Value>(
        _ path: WritableKeyPath<Root, Value>,
        values: [Value]
    ) {
        self.keyPath = path
        self.set = { root, value in
            root[keyPath: path] = value as! Value
        }
        self.values = values
    }
}

public func allInvariantCombinations<T>(
    _ base: T,
    wildcardPaths: [WildcardPath<T>] = []
) -> [T] {

    let combined: [(PartialKeyPath<T>, (inout T, Any) -> Void, [Any])] =
        wildcardPaths.map { wildcardPath in
            switch wildcardPath {
            case let .auto(writablePath):
                return (writablePath.keyPath, writablePath.set, writablePath.getAllValues())
            case let .options(overridenPath):
                return (overridenPath.keyPath, overridenPath.set, overridenPath.values)
            }
        }

    // Cartesian product of values (to generate all combos)
    func product(_ sets: [[Any]]) -> [[Any]] {
        sets.reduce([[]]) { acc, values in
            acc.flatMap { prefix in values.map { prefix + [$0] } }
        }
    }

    let allValueSets = combined.map { $0.2 }

    return product(allValueSets).map { values in
        var copy = base
        for (i, value) in values.enumerated() {
            let setter = combined[i].1
            setter(&copy, value)
        }
        return copy
    }
}

public enum InvariantCombinator {
    public static func testCases<T>(
        from prototype: @autoclosure () -> T,
        wildcardPaths: [WildcardPath<T>] = []
    ) -> [T] {
        allInvariantCombinations(prototype(), wildcardPaths: wildcardPaths)
    }
}

// syntactic sugar

public func anyWritable<Root, Value: InvariantValues>(
    _ keyPath: WritableKeyPath<Root, Value>
) -> AnyWritableKeyPath<Root> {
    AnyWritableKeyPath(keyPath)
}
