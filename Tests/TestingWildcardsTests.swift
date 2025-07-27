import Foundation
import Testing
//import TestingWildcards
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
                .wild(\.flag),
                .wild(\.mode),
            ]
        )

        #expect(combinations.count == 6)
        #expect(combinations.contains(where: {
            $0.flag == false && $0.mode == .alpha //&& $0.name == "bob"
        }))

        print(combinations)
    }

    //    @Test
    //    func resultTypes() {
    //        typealias MyResult = Result<Bool, SomeError>
    //        // Results aren't mutable! Guess we could built something to instantiate it, but... meh
    //        let base = MyResult.success(true)
    //    }

    @Test
    func manualWildcards() {
        // MARK: - Generate All Combinations
        let base = Example(name: "bob", flag: false, mode: .alpha, count: 0)

        let combinations = allInvariantCombinations(
            base,
            wildcardPaths: [
                .values(\.count, [0, 5])
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
                .wild(\.flag),
                .wild(\.mode),
                .values(\.count, [0, 5])
            ]
        )

        #expect(combinations.count == 12)
        #expect(combinations.contains(where: {
            $0.flag == false && $0.mode == .alpha
        }))
        print(combinations)
    }

    /// duplication of repeated wildcards is not desirable behaivour,
    /// but I'm tracking it here as *known* behaviour
    @Test
    func repeatedSimpleWildcardsAreDuplicated() {
        // MARK: - Generate All Combinations
        let base = Example(name: "bob", flag: false, mode: .alpha, count: 0)

        let combinations = allInvariantCombinations(
            base,
            wildcardPaths: [
                .wild(\.flag),
                .wild(\.flag),
                .wild(\.mode)
            ]
        )
        // the repeated .simple(\.flag) gives us 2x2x3 = 12 combos. Ideally it wouldn't
        // and we'd have only 6.
        #expect(combinations.count == 12)
    }

    /// duplication of repeated wildcards is not desirable behaivour,
    /// but I'm tracking it here as *known* behaviour
    @Test
    func repeatedManualWildcardsAreDuplicated() {
        // MARK: - Generate All Combinations
        let base = Example(name: "bob", flag: false, mode: .alpha, count: 0)

        let combinations = allInvariantCombinations(
            base,
            wildcardPaths: [
                .wild(\.flag),
                .values(\.count, [0, 5, 10]),
                .values(\.count, [0, 5, 10])
            ]
        )
        // the repeated .manual gives us 2x3x3 = 18 combos. Ideally it wouldn't
        // and we'd have only 6.
        #expect(combinations.count == 18)
    }

    // use the combos gen in actually Test arguments
    @Test(arguments:
            allInvariantCombinations(
                Example(name: "bob", flag: false, mode: .alpha, count: 0),
                wildcardPaths: [
                    .wild(\.flag),
                    .values(\.count, [0, 5, 10]),
                    .values(\.count, [0, 5, 10])
                ])
    )
    func repeatedManualWildcardsAreDuplicated(_ example: Example) {
        // test something always true while invariants changing
        #expect(example.name == "bob")
    }

    // use the combos gen in actually Test arguments, in base.call style
    @Test(arguments:
        Example.allInvariantCombinations(
            wildcardPaths: [
                .wild(\.flag),
                .values(\.count, [0, 5, 10]),
                .values(\.count, [0, 5, 10])
            ])
    )
    func repeatedManualWildcardsAreDuplicated_callStyle2(_ example: Example) {
        // test something always true while invariants changing
        #expect(example.name == "bob")
    }
}
