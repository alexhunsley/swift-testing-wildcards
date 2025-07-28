// swift-tools-version:5.9
import PackageDescription


// AH: this was created manually for SPM publishing
let package = Package(
    name: "TestingWildcards",
    platforms: [
        .iOS(.v15)
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
            path: "Sources",
            sources: [
                "TestingWildcards.swift",
                "TestingWildcardsApp.swift",
                "Helpers",
                "Invariants"
            ]
        ),
        .testTarget(
            name: "TestingWildcardsTests",
            dependencies: ["TestingWildcards"],
            path: "Tests",
            sources: [
                "TestingWildcardsTests.swift",
                "WildcardTestHelpers.swift"
            ]
        )
    ]
)
