import Foundation
//import Testing

var greeting = "Hello, playground"

public protocol InvariantValues {
    static var allValues: [Self] { get }
}

extension Bool: InvariantValues {
    public static let allValues = [true, false]
}

extension InvariantValues where Self: CaseIterable {
    public static var allValues: [Self] { Array(Self.allCases) }
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

//public struct OverriddenKeyPath<Root> {
//    public let keyPath: WritableKeyPath<Root, Any>
//    public let values: [Any]
//
//    public init<Value>(_ keyPath: WritableKeyPath<Root, Value>, values: [Value]) {
//        self.keyPath = keyPath as! WritableKeyPath<Root, Any>
//        self.values = values
//    }
//
//    public static func == (lhs: OverriddenKeyPath<Root>, rhs: OverriddenKeyPath<Root>) -> Bool {
//        lhs.keyPath == rhs.keyPath
//    }
//
//    public func hash(into hasher: inout Hasher) {
//        hasher.combine(keyPath)
//    }
//}

public func allInvariantCombinations<T>(
    _ base: T,
    keyPaths: [AnyWritableKeyPath<T>] = [],
    overrides: [OverriddenKeyPath<T>] = []
) -> [T] {
    // Collect all sets to permute
    let combined: [(PartialKeyPath<T>, (inout T, Any) -> Void, [Any])] =

        keyPaths.map {
            ($0.keyPath, $0.set, $0.getAllValues())
        } +

        overrides.map { override in
            (override.keyPath, override.set, override.values)
        }
//        overrides.map { override in
//            (override.keyPath, { (root: inout T, value: Any) in
//                root[keyPath: override.keyPath] = value
//            }, override.values)
//        }

    // Cartesian product of values
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
        keyPaths: [AnyWritableKeyPath<T>] = [],
        overrides: [OverriddenKeyPath<T>] = []
    ) -> [T] {
        allInvariantCombinations(prototype(), keyPaths: keyPaths, overrides: overrides)
    }
}

// syntactic sugar

public func anyWritable<Root, Value: InvariantValues>(
    _ keyPath: WritableKeyPath<Root, Value>
) -> AnyWritableKeyPath<Root> {
    AnyWritableKeyPath(keyPath)
}
