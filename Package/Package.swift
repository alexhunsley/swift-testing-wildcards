// swift-tools-version:5.9
import PackageDescription


// AH: this was created manually for SPM publishing
let package = Package(
    name: "TestingWildcards",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "TestingWildcards",
            targets: ["TestingWildcards"]
        ),
    ],
    targets: [
        .target(
            name: "TestingWildcards",
            path: "Sources/TestingWildcards",
            sources: [
                "TestingWildcards.swift",
                "Helpers",
                "Invariants"
            ]
        ),
        .testTarget(
            name: "TestingWildcardsTests",
            dependencies: ["TestingWildcards"],
            path: "Tests/TestingWildcardsTests",
            sources: [
                "TestingWildcardsTests.swift",
                "WildcardTestHelpers.swift"
            ]
        )
    ]
)
