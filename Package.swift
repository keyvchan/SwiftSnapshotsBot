// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftSnapshotsBot",
    products: [
        .executable(name: "SwiftSnapshotsBot", targets: ["SwiftSnapshotsBot"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.1.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.2.0"),
        .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "2.3.0"),
        .package(url: "https://github.com/malcommac/SwiftDate.git", from: "6.1.0"),
        .package(url: "https://github.com/IBM-Swift/HeliumLogger", from: "1.9.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "SwiftSnapshotsBot",
            dependencies: [
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "SwiftSoup", package: "SwiftSoup"),
                .product(name: "SwiftDate", package: "SwiftDate"),
                .product(name: "HeliumLogger", package: "HeliumLogger"),
            ]
        ),
        .testTarget(
            name: "SwiftSnapshotsBotTests",
            dependencies: ["SwiftSnapshotsBot"]
        ),
    ]
)
