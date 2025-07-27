import ProjectDescription

let project = Project(
    name: "TestingWildcards",
    targets: [
        .target(
            name: "TestingWildcards",
            destinations: .iOS,
            product: .app,
            bundleId: "dev.tuist.TestingWildcards",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            sources: ["Sources/**"],
//            resources: ["Resources/**"],
            dependencies: []
        ),
        .target(
            name: "TestingWildcardsTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "dev.tuist.TestingWildcardsTests",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Tests/**"],
            resources: [],
            dependencies: [.target(name: "TestingWildcards")]
        ),
//        .target(
//            name: "MacroTest",
//            destinations: .iOS,
//            product: .unitTests,
//            bundleId: "dev.tuist.TestingWildcardsTests",
//            dependencies: [
//                "TestingWildcards",
//                "TestingWildcardsTests",
//                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax")
//            ]
//        )
    ],
    additionalFiles: [
        "README.md"
    ]
)
