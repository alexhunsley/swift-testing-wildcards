import Foundation
import Testing
import TestingWildcards
import CustomDump

final class TestingWildcardsTests {
    @Test
    func wildcards() {
        let combinations = Example.variants(
            .wild(\.flag),
            .wild(\.mode)
        )
        #expect(combinations.count == 6)
        #expect(combinations.contains(where: {
            $0.flag == false && $0.mode == .alpha
        }))
    }

    @Test
    func values() {
        let combinations = Example.variants(
            .values(\.count, [0, 5])
        )
        #expect(combinations.count == 2)
        #expect(combinations.contains(where: {
            $0.flag == false && $0.mode == .alpha
        }))
    }

    @Test
    func callingInvariantCombinationsWithPrototype() {
        let base = Example(name: "bob", flag: false, mode: .alpha, count: 0)

        let combinations = base.variants(
            .wild(\.flag),
            .wild(\.mode),
            .values(\.count, [0, 5])
        )
        #expect(combinations.count == 12)
        #expect(combinations.contains(where: {
            $0.flag == false && $0.mode == .alpha
        }))
    }

    @Test
    func wildcardsAndValuesIncludingOptional() {
        // MARK: - Generate All Combinations
        let base = Example(name: "alex", flag: false, mode: .alpha, count: 0)

        let combinations = base.variants(
            .wild(\.error),
            .wild(\.mode),
            .values(\.count, [0, 5])
        )

        #expect(combinations.count == 18)
        #expect(combinations.contains(where: {
            $0.count == 5 && $0.mode == .alpha
        }))
    }

    /// duplication of repeated wildcards is not desirable behaivour,
    /// but I'm tracking it here as *known* behaviour
    @Test
    func repeatedSimpleWildcardsAreDuplicated() {
        // MARK: - Generate All Combinations
        let base = Example(name: "bob", flag: false, mode: .alpha, count: 0)

        let combinations = base.variants(
            .wild(\.flag),
            .wild(\.flag),
            .wild(\.mode)
        )
        // the repeated .simple(\.flag) gives us 2x2x3 = 12 combos. Ideally it wouldn't
        // and we'd have only 6.
        #expect(combinations.count == 12)
    }

    /// duplication of repeated wildcards is not desirable behaivour,
    /// but I'm tracking it here as *known* behaviour
    @Test
    func repeatedManualWildcardsAreDuplicated() {
        let combinations = Example.variants(
            .wild(\.flag),
            .values(\.count, [0, 5, 10]),
            .values(\.count, [0, 5, 10])
        )
        // the repeated .manual gives us 2x3x3 = 18 combos. Ideally it wouldn't
        // and we'd have only 6.
        #expect(combinations.count == 18)
    }

    @Test(arguments:
            Example(name: "bob", flag: false, mode: .alpha, count: 0).variants (
                .wild(\.error),
                .wild(\.mode)
            )
    )
    func usingAnOptionalError(_ example: Example) {
        // test something always true while invariants changing
        #expect(example.name == "bob")
    }

    @Test(arguments: Example.variants())
    func givingNoParamsToVariantsGivesPlainPrototype(example: Example) {
        #expect(example == Example.init())
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

    // passing in explicit list to variants()
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

    // custom instance (not standard prototype) variants
    @Test(arguments:
            Example(name: "sue", flag: false, mode: .alpha, count: 0)
        .variants(
            .wild(\.flag),
            .values(\.count, [0, 5, 10]),
            .values(\.count, [0, 5, 10])
        )
    )
    func repeatedManualWildcardsAreDuplicated_onCustomIntance(_ example: Example) {
        // test something always true while invariants changing
        #expect(example.name == "sue")
    }

    // use the combos gen in actually Test arguments, in base.call style
    @Test(arguments:
            Example.variants(
                .wild(\.flag),
                .values(\.count, [0, 5, 10]),
                .values(\.count, [0, 5, 10])
            )
    )
    func repeatedManualWildcardsAreDuplicated(_ example: Example) {
        // test something always true while invariants changing
        #expect(example.name == "bob")
    }

    // Getting all the variants passed in at once!
    // Do this by putting [ ] around the arguments and around param to func.
    // maybe if you want to test the expect total variant count.
    // * SEE ALSO variantsList below, which is nicer.
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

    // Getting all the variants passed in at once by using variantsList (instead of [ ])
    // Do this by putting [ ] around the param to func only.
    // could be used if you want to test the expect total variant count.
    @Test(arguments:
            Example.variantsList(
                .wild(\.flag),
                .values(\.count, [0, 5, 10]),
            )
    )
    func variantsListPassesInAllVariantsAsOneList(_ examples: [Example]) {
        // we can count the variants because we've passed them all in at once
        #expect(examples.count == 6)
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

    @Test(arguments:
            Example.variants(
                .wild(\.flag),
                .wild(\.mutableResult)
            )
    )
    func mutableResultValues(_ example: Example) {
        // test something always true while invariants changing
        #expect(example.name == "bob")
    }

    @Test(arguments:
            Example.variantsList(
                .wild(\.mutableResult)
            )
    )
    func mutableResultValuesAll(_ examples: [Example]) {
        // test something always true while invariants changing
        #expect(examples.count == 4)

//        print("MutableResult examples: ")
//        customDump(examples.map { $0.mutableResult })
        //        print("MutableResult examples: ", examples.map { $0.mutableResult })
    }

    @Test(arguments:
        Example.variantsList(
            .wild(\.flag),
            .wild(\.mutableResult)
        )
    )
    func mutableResultValuesAllPlusFlag(_ examples: [Example]) {
        // test something always true while invariants changing
        #expect(examples.count == 8)

        print("MutableResult examples: ")
        customDump(examples.map { $0.mutableResult })
//        print("MutableResult examples: ", examples.map { $0.mutableResult })
    }
}
