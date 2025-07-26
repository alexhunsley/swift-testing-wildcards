import Foundation
import Testing
@testable import TestingWildcards

final class TestingWildcardsTests {
    @Test
    func twoPlusTwo_isFour() {
        #expect(2 + 2 == 4)
    }

    @Test
    func wildcards() {
        // MARK: - Generate All Combinations
        let base = Example(name: "bob", flag: false, mode: .alpha, count: 0)

        let combinations = allInvariantCombinations(
            base,
            wildcardPaths: [
                .simple(anyWritable(\.flag)), // need the cast here? to AnyWritableKeyPath
                .simple(anyWritable(\.mode)),
                .manual(OverriddenKeyPath(\.count, values: [0, 5]))
            ]
        )

        #expect(combinations.count == 12)
        #expect(combinations.contains(where: {
            $0.flag == false && $0.mode == .alpha
        }))

        print(combinations)
        //
        //        for combo in combinations {
        //            print(combo)
        //        }
    }

//    @Test(arguments:
//        InvariantCombinator.testCases(
//            from: Example(name: "bob", flag: false, mode: .alpha, count: 0),
//            wildcardPaths:
////            keyPaths: [
////    //                AnyWritableKeyPath(\.flag),
////                anyWritable(\.flag),
////            ]
//        )
//
//
////        InvariantCombinator.testCases(
////            from: Example(name: "bob", flag: false, mode: .alpha, count: 0),
////            keyPaths: [
//////                AnyWritableKeyPath(\.flag),
////                anyWritable(\.flag),
////            ],
////            overrides: [
////                OverriddenKeyPath(\.name, values: ["alex", "goom"]),
////                OverriddenKeyPath(\.count, values: [0, 10])
////            ]
////        )
//    )
//    func testVariants(input: Example) {
//        print("got input: \(input)")
//    }
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
