import ProjectDescription

let project = Project(
    name: "InvariantProject",
    targets: [
        .target(
            name: "InvariantCombinator",
            destinations: .iOS,
            product: .staticLibrary,
            bundleId: "com.example.InvariantCombinator",
            sources: ["Sources/InvariantCombinator/**"],
            dependencies: []
        ),
        .target(
            name: "InvariantCombinatorTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.example.InvariantCombinatorTests",
            sources: ["Tests/InvariantCombinatorTests/**"],
            dependencies: [.target(name: "InvariantCombinator")],
            settings: .settings(
                base: [
                    "ENABLE_PREVIEWS": "YES",
                    "ENABLE_TESTING_SEARCH_PATHS": "YES",
                    "SWIFT_ENABLE_EXPERIMENTAL_FEATURES": "EmbeddedTesting"
                ]
            )
        )
    ]
)
