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

    @Test
    func wildcardsOfBothKindsWithAnOptional() {
        // MARK: - Generate All Combinations
        let base = Example(name: "bob", flag: false, mode: .alpha, count: 0)

        let combinations = allInvariantCombinations(
            base,
            wildcardPaths: [
                //                .simple(\.flag), // TODO if you pass same flag multiple times you get repeated combos!
                .wild(\.error),
                .wild(\.mode),
                .values(\.count, [0, 5])
            ]
        )

        #expect(combinations.count == 18)
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

    ///
    // use the combos gen in actually Test arguments

    // Is there a helper could make to get the actual list of invariants in the test
    // as well as each one passed the usual way?
    // hmm doesn't really make sense. Could just pass in the invariants
    // and manually loop over them, but then we lose the power of the results
    // listing each combo.

    // using the top level allInvariantCombinations() -- not as nice as later ones!
    @Test(arguments:
        allInvariantCombinations(
            Example(name: "bob", flag: false, mode: .alpha, count: 0),
            wildcardPaths: [
                .wild(\.error),
                .wild(\.mode)
            ])
    )
    func usingAnOptionalError(_ example: Example) {
        // test something always true while invariants changing
        #expect(example.name == "bob")
    }

    // variadic
    @Test(arguments:
            Example.variants(
                .wild(\.error),
                .wild(\.mode)
            )
    )
    func usingAnOptionalError2_variadic(_ example: Example) {
        // test something always true while invariants changing
        #expect(example.name == "bob")
    }

    // explicit list
    @Test(arguments:
            Example.variants([
                .wild(\.error),
                .wild(\.mode)
            ])
    )
    func usingAnOptionalError2_explicitList(_ example: Example) {
        // test something always true while invariants changing
        #expect(example.name == "bob")
    }

    // triying to use filter/remove but get //  "could't type check this is reasonable time"
    // explicit list, with `removing(where: )`
    //    @Test(arguments:
    //            Example.variants([
    //                .wild(\.error),
    //                .wild(\.mode)
    //            ]
    ////            .remove
    ////            .filter { x in true }
    //                             //  "could't type check this is reasonable time"
    ////                .remove { ex in
    ////                    ex.error == nil && ex.mode == Mode.alpha
    ////                }
    //        )
    //    )
    //    func usingAnOptionalError2_explicitList_usingRemoving(_ example: Example) {
    //        // test something always true while invariants changing
    //        #expect(example.name == "bob")
    //        // we will never see this combo due to the 'removing'
    ////        #expect(!(example.error == nil && example.mode == .alpha))
    //    }


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
        Example.variants(
            .wild(\.flag),
            .values(\.count, [0, 5, 10]),
            .values(\.count, [0, 5, 10])
        )
    )
    func repeatedManualWildcardsAreDuplicated_callStyle2(_ example: Example) {
        // test something always true while invariants changing
        #expect(example.name == "bob")
    }

    // Getting all the variants passed in at once!
    // Do this by putting [ ] around the arguments and around param to func.
    // maybe if you want to test the expect total variant count.
    @Test(arguments:
        [Example.variants(
            .wild(\.flag),
            .values(\.count, [0, 5, 10]),
            .values(\.count, [0, 5, 10])
        )]
    )
    func repeatedManualWildcardsAreDuplicated_callStyle2b(_ examples: [Example]) {
        // test something always true while invariants changing
//        #expect(example.name == "bob")
        #expect(examples.count == 18)
    }


    @Test(arguments:
        Example.variants(
            .wild(\.flag),
            .values(\.count, 10...12),
            .values(\.mode, [.beta, .gamma]),
            .values(\.a, stride(from: 2, to: 4, by: 2)),
            .values(\.b, stride(from: 0, through: 5, by: 3)),
            .values(\.c, [20, 31, 56]),
        )
    )
    func valuesAsRange(_ example: Example) {
        // test something always true while invariants changing
        print("GOT: \(example)")
        #expect(example.name == "bob")
        #expect(10...12 ~= example.count)
    }

    @Test(arguments:
        Example.variants(
                .wild(\.filePermission),
                .values(\.count, 10...12),
        )
    )
    func optionSetValues(_ example: Example) {
        // test something always true while invariants changing
        #expect(example.name == "bob")
        #expect(10...12 ~= example.count)
    }
}
