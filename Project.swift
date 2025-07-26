import ProjectDescription

let project = Project(
    name: "TestingWildcards",
    targets: [
        .target(
            name: "TestingWildcards",
            destinations: .iOS,
            product: .app,
            bundleId: "dev.tuist.TestingWildcards",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: []
        ),
        .target(
            name: "TestingWildcardsTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "dev.tuist.TestingWildcardsTests",
            infoPlist: .default,
            sources: ["Tests/**"],
            resources: [],
            dependencies: [.target(name: "TestingWildcards")]
        ),
    ]
)
