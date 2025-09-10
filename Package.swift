// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FastPath",
    platforms: [
        .iOS(.v16)
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.19.1"),
        .package(url: "https://github.com/pointfreeco/swift-structured-queries", from: "0.2.0"),
        .package(url: "https://github.com/groue/GRDB.swift", from: "7.5.0"),
        .package(url: "https://github.com/pointfreeco/sharing-grdb", from: "0.2.2")
    ],
    targets: [
        .target(
            name: "FastPath",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "StructuredQueries", package: "swift-structured-queries"),
                .product(name: "GRDB", package: "GRDB.swift"),
                .product(name: "SharingGRDB", package: "sharing-grdb")
            ]
        )
    ]
)
