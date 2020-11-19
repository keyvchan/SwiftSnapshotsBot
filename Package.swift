// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftSnapshotsBot",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .executable(name: "SwiftSnapshotsBot", targets: ["SwiftSnapshotsBot"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.1.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.2.0"),
        .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "2.3.0"),
        .package(url: "https://github.com/Maxim-Inv/SwiftDate.git", .branch("master")),
        .package(url: "https://github.com/vapor/console-kit", from: "4.0.0"),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.0"),

        // Beta version, need to switch to stable when it official release.
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
                .product(name: "ConsoleKit", package: "console-kit"),
                .product(name: "SwiftyJSON", package: "SwiftyJSON")
            ]
        ),
        .testTarget(
            name: "SwiftSnapshotsBotTests",
            dependencies: ["SwiftSnapshotsBot"]
        ),
    ]
)
