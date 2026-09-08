// swift-tools-version:6.2

import PackageDescription

let package = Package(
    name: "swift-create-xcframework",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .executable(name: "swift-create-xcframework", targets: ["CreateXCFramework"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", exact: "1.4.0"),
        .package(
            url: "https://github.com/apple/swift-package-manager.git",
            revision: "215e9f91823d7e44c379fa17bf1eef189438fc24"
        ),
    ],
    targets: [
        .target(
            name: "Xcodeproj",
            dependencies: [
                .product(name: "SwiftPM-auto", package: "swift-package-manager"),
            ]
        ),
        .target(
            name: "CreateXCFramework",
            dependencies: [
                "Xcodeproj",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SwiftPM-auto", package: "swift-package-manager"),
            ]
        ),
        .testTarget(name: "CreateXCFrameworkTests", dependencies: ["CreateXCFramework"]),
    ],
    swiftLanguageModes: [.v5]
)
