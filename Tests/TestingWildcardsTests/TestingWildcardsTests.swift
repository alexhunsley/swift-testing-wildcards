import Testing
import TestingWildcards

final class TestingWildcardsTests {
    @Test(arguments:
            Example.variantsList(
                .wild(\.mode)
            )
    )
    func wildcard(examples: [Example]) {
        #expect(examples.count == 3)
        #expect(examples.contains(where: {
            $0.flag == false && $0.mode == .alpha
        }))
    }

    @Test(arguments:
            Example.variantsList(
                .wild(\.flag),
                .wild(\.mode)
            )
    )
    func wildcards(examples: [Example]) {
        #expect(examples.count == 6)
        #expect(examples.contains(where: {
            $0.flag == false && $0.mode == .alpha
        }))
    }

    @Test(arguments:
            Example.variantsList(
                .values(\.count, 3)
            )
    )
    func value(examples: [Example]) {
        #expect(examples.count == 1)
    }

    @Test(arguments:
            Example.variantsList(
                .values(\.count, [5, 4]),
                .values(\.a, [11,57])
            )
    )
    func values(examples: [Example]) {
        #expect(examples.count == 4)
    }

    @Test(arguments:
            Example.variantsList(
                .values(\.count, [5, 4]),
                .values(\.a, [11,57]),
                .wild(\.flag),
                .wild(\.mode)
            )
    )
    func valuesAndWildcards(examples: [Example]) {
        #expect(examples.count == 24)
    }

    @Test(arguments:
            Example.variants(
                .values(\.count, [5, 4]),
                .values(\.a, [11, 57]),
                .wild(\.flag),
                .wild(\.mode)
            )
            .filter { $0.mode != .alpha && $0.a != 11}
    )
    func valuesAndWildcards_filter(example: Example) {
        #expect(example.mode != .alpha && example.a != 11)
    }

    @Test(arguments:
            Example(name: "bob", flag: false, mode: .alpha, count: 0)
                .variantsList(
                    .wild(\.flag),
                    .wild(\.mode),
                    .values(\.count, [0, 5])
            )
    )
    func usingManualPrototype(examples: [Example]) {
        #expect(examples.count == 12)
        #expect(examples.contains(where: {
            $0.flag == false && $0.mode == .alpha
        }))
    }

    @Test(arguments:
            Example(name: "alex", flag: false, mode: .alpha, count: 0)
                .variantsList(
                    .wild(\.error),
                    .wild(\.mode),
                    .values(\.count, [0, 5])
                )
    )
    func wildcardsAndValuesIncludingOptional(examples: [Example]) {
        // MARK: - Generate All Combinations
        #expect(examples.count == 18)
        #expect(examples.contains(where: {
            $0.count == 5 && $0.mode == .alpha
        }))
    }

    @Test(arguments: Example.variants())
    func givingNoParamsToVariantsGivesPlainPrototype(example: Example) {
        #expect(example == Example.init())
    }

    @Test(arguments: Example.variantsList())
    func givingNoParamsToVariantsGivesPlainPrototype_asList(examples: [Example]) {
        #expect(examples == [Example.init()])
    }

    @Test(arguments:
            Example.variantsList(
                .wild(\.error),
                .wild(\.mode)
            )
    )
    func usingAnOptionalError(_ examples: [Example]) {
        #expect(examples.count == 9)
    }

    // custom instance (not standard prototype) variants
    @Test(arguments:
            Example(name: "sue", flag: false, mode: .alpha, count: 0)
                .variantsList(
                    .wild(\.flag),
                    .values(\.count, [0, 5, 10]),
                    .values(\.count, [0, 5, 10])
        )
    )
    func repeatedManualWildcardsAreDuplicated_onCustomIntance(_ examples: [Example]) {
        #expect(examples.count == 18)
    }

    // use the combos gen in actually Test arguments, in base.call style
    @Test(arguments:
            Example.variantsList(
                .wild(\.flag),
                .values(\.count, [0, 5, 10]),
                .values(\.count, [0, 5, 10])
            )
    )
    func repeatedManualWildcardsAreDuplicated(_ examples: [Example]) {
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
            Example.variantsList(
                .wild(\.flag),
                .values(\.count, 10...12),
                .values(\.mode, [.beta, .gamma]),
                .values(\.a, stride(from: 2, to: 4, by: 2)),
                .values(\.b, stride(from: 0, through: 5, by: 3)),
                .values(\.c, [20, 31, 56]),
            )
    )
    func valuesAsRange(_ examples: [Example]) {
        #expect(examples.count == 72)
    }

    @Test(arguments:
            Example.variants(
                .wild(\.filePermission),
                .values(\.count, 10...12),
            )
    )
    func optionSetValues(_ example: Example) {
        #expect(example.name == "bob")
        #expect(10...12 ~= example.count)
    }

    @Test(arguments:
            Example.variantsList(
                .wild(\.filePermission),
                .values(\.count, 10...12),
            )
    )
    func optionSetValues_asList(_ examples: [Example]) {
        #expect(examples.count == 24)
    }

    // MARK: - Result type

    @Test(arguments:
            Example.variantsList(
                .wild(\.flag),
                .wild(\.result)
            )
    )
    func resultWild(_ examples: [Example]) {
        #expect(examples.count == 8)
    }

    @Test(arguments:
            Example.variantsList(
                .wild(\.flag),
                .wild(\.resultNeverError)
            )
    )
    func resultNeverErrorWild_asList(_ examples: [Example]) {
        #expect(examples.count == 4)
    }

    @Test(arguments:
            Example.variantsList(
                .wild(\.flag),
                .wild(\.resultNeverSuccess)
            )
    )
    func resultNeverSuccessWild_asList(_ examples: [Example]) {
        #expect(examples.count == 4)
    }

    @Test(arguments:
            Example.variantsList(
                .wild(\.flag),
                .wild(\.resultOptionalSuccessNeverError)
            )
    )
    func resultOptionalSuccessNeverErrorWild(_ examples: [Example]) {
        #expect(examples.count == 6)
    }

    @Test(arguments:
            Example.variantsList(
                .wild(\.resultOptionalSuccessNeverError)
            )
    )
    func resultOptionalSuccessNeverErrorWild_asList(_ examples: [Example]) {
        #expect(examples.count == 3)
    }

    // MARK: - Tests using variantList to verify combos counts

    @Test(arguments:
            Example.variantsList(
                .wild(\.result)
            )
    )
    func resultValuesAll_asList(_ examples: [Example]) {
        #expect(examples.count == 4)
    }

    @Test(arguments:
            Example.variantsList(
                .wild(\.flag),
                .wild(\.result)
            )
    )
    func resultValuesAllPlusFlag_asList(_ examples: [Example]) {
        #expect(examples.count == 8)
    }

    @Test(arguments:
            Example.variantsList(
                .wild(\.result)
            )
    )
    func result_asList(_ examples: [Example]) {
        #expect(examples.count == 4)
    }

    @Test(arguments:
            Example.variantsList(
                .wild(\.resultOptionalSuccess)
            )
    )
    func resultWithOptionalSuccess_asList(_ examples: [Example]) {
        #expect(examples.count == 5)
    }
}

// MARK: - Tracking known bad behaviour
/// duplication of repeated wildcards is not desirable behaivour,
extension TestingWildcardsTests {
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
}
