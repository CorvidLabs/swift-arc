// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-arc",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .tvOS(.v16),
        .watchOS(.v9),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "ARC",
            targets: ["ARC"]
        )
    ],
    dependencies: [
        .package(path: "../swift-algorand"),
        .package(path: "../swift-pinata"),
        .package(
            url: "https://github.com/apple/swift-crypto.git",
            from: "3.0.0"
        ),
        .package(
            url: "https://github.com/swiftlang/swift-docc-plugin",
            from: "1.4.3"
        )
    ],
    targets: [
        .target(
            name: "ARC",
            dependencies: [
                .product(name: "Algorand", package: "swift-algorand"),
                .product(name: "Pinata", package: "swift-pinata"),
                .product(name: "Crypto", package: "swift-crypto")
            ]
        ),
        .testTarget(
            name: "ARCTests",
            dependencies: ["ARC"]
        )
    ]
)
