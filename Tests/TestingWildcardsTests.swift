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
            keyPaths: [
                AnyWritableKeyPath(\Example.flag),
                AnyWritableKeyPath(\Example.mode)
            ]
        )

        #expect(combinations.count == 6)
        #expect(combinations.contains(where: {
            $0.flag == false && $0.mode == .alpha
        }))

        print(combinations)
        //
        //        for combo in combinations {
        //            print(combo)
        //        }
    }


    @Test(arguments:
            InvariantCombinator.testCases(
                from: Example(name: "bob", flag: false, mode: .alpha, count: 0),
                keyPaths: [
                    //                    AnyWritableKeyPath(\Example.flag),
                    anyWritable(\Example.flag),
//                    anyWritable(\Example.count),

//                    anyWritable(\Example.mode),
//                    anyWritable(\Example.count) // error as expected: Global function 'anyWritable' requires that 'Int' conform to 'InvariantValues'

                ],
                overrides: [
                    OverriddenKeyPath(\.count, values: [0, 10])
                ]
            )
    )
    func testVariants(input: Example) {
        print("got input: \(input)")
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
    let name: String
    var flag: Bool
    var mode: Mode
    var count: Int

    var description: String {
        "[Example name: \(name) flag: \(flag), mode: \(mode), count: \(count)])"
    }
}
