import Foundation
import Testing
@testable import TestingWildcards

final class TestingWildcardsTests {
    @Test
    func twoPlusTwo_isFour() {
        #expect(2 + 2 == 4)
    }

    @Test
    func simpleWildcards() {
        // MARK: - Generate All Combinations
        let base = Example(name: "bob", flag: false, mode: .alpha, count: 0)

        let combinations = allInvariantCombinations(
            base,
            wildcardPaths: [
                .simple(\.flag),
                .simple(anyWritable(\.mode)),
            ]
        )

        #expect(combinations.count == 6)
        #expect(combinations.contains(where: {
            $0.flag == false && $0.mode == .alpha //&& $0.name == "bob"
        }))

        print(combinations)
    }

    @Test
    func manualWildcards() {
        // MARK: - Generate All Combinations
        let base = Example(name: "bob", flag: false, mode: .alpha, count: 0)

        let combinations = allInvariantCombinations(
            base,
            wildcardPaths: [
                .manual(\.count, values: [0, 5])
            ]
        )

        #expect(combinations.count == 2)
        #expect(combinations.contains(where: {
            $0.flag == false && $0.mode == .alpha
        }))
        print(combinations)
    }

    @Test
    func wildcardsOfBothKinds() {
        // MARK: - Generate All Combinations
        let base = Example(name: "bob", flag: false, mode: .alpha, count: 0)

        let combinations = allInvariantCombinations(
            base,
            wildcardPaths: [
                //                .simple(\.flag), // TODO if you pass same flag multiple times you get repeated combos!
                .simple(\.flag),
                .simple(\.mode),
                .manual(\.count, values: [0, 5])
            ]
        )

        #expect(combinations.count == 12)
        #expect(combinations.contains(where: {
            $0.flag == false && $0.mode == .alpha
        }))
        print(combinations)
    }

    @Test
    func repeatedSimpleWildcardsDoNotDuplicate() {
        // MARK: - Generate All Combinations
        let base = Example(name: "bob", flag: false, mode: .alpha, count: 0)

        let combinations = allInvariantCombinations(
            base,
            wildcardPaths: [
                .simple(\.flag),
                .simple(\.flag),
            ]
        )
        // if we have > 2 combinations, we are duplicating the same thing that was listed twice
        #expect(combinations.count == 2)
    }
}

// MARK: - Example Enum and Struct

enum Mode: CaseIterable, InvariantValues, CustomStringConvertible {
    case alpha, beta, gamma

    var description: String {
        switch self {
        case .alpha: return "Alpha"
        case .beta: return "Beta"
        case .gamma: return "Gamma"
        }
    }
}

struct Example: CustomStringConvertible {
    var name: String
    var flag: Bool
    var mode: Mode
    var count: Int

    var description: String {
        "[Example name: \(name) flag: \(flag), mode: \(mode), count: \(count)])"
    }
}
