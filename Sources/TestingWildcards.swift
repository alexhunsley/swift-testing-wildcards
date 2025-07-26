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

public func allInvariantCombinations<T>(
    _ base: T,
    keyPaths: [AnyWritableKeyPath<T>],
    valueOverrides: [PartialKeyPath<T>: () -> [Any]] = [:]
) -> [T] {
    // ah of course, you must list your manual value set thing in the keyPaths
    // or else it's not used!
    let allValueSets: [[Any]] = keyPaths.map { keyPath in
        valueOverrides[keyPath.keyPath]?() ?? keyPath.getAllValues()
    }

    print("Merged value sets: \(allValueSets)")

    func cartesianProduct(_ sets: [[Any]]) -> [[Any]] {
        sets.reduce([[]]) { acc, values in
            acc.flatMap { prefix in values.map { prefix + [$0] } }
        }
    }

    return cartesianProduct(allValueSets).map { values in
        var copy = base
        for (value, keyPath) in zip(values, keyPaths) {
            keyPath.set(&copy, value)
        }
        return copy
    }
}

public enum InvariantCombinator {
    public static func testCases<T>(
        from prototype: @autoclosure () -> T,
        keyPaths: [AnyWritableKeyPath<T>],
        valueOverrides: [PartialKeyPath<T>: () -> [Any]] = [:]
    ) -> [T] {
        allInvariantCombinations(prototype(), keyPaths: keyPaths, valueOverrides: valueOverrides)
    }
}

// syntactic sugar

public func anyWritable<Root, Value: InvariantValues>(
    _ keyPath: WritableKeyPath<Root, Value>
) -> AnyWritableKeyPath<Root> {
    AnyWritableKeyPath(keyPath)
}
