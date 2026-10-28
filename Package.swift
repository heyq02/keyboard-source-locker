// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "KeyboardSourceLocker",
    platforms: [
        .macOS(.v14),
    ],
    products: [
        .library(
            name: "KeyboardSourceLocker",
            targets: ["KeyboardSourceLocker"]
        ),
        .executable(
            name: "KeyboardSourceLockerApp",
            targets: ["KeyboardSourceLockerApp"]
        ),
        .executable(
            name: "CoreTestRunner",
            targets: ["CoreTestRunner"]
        ),
    ],
    targets: [
        .target(
            name: "KeyboardSourceLocker",
            linkerSettings: [
                .linkedFramework("Carbon"),
            ]
        ),
        .executableTarget(
            name: "KeyboardSourceLockerApp",
            dependencies: ["KeyboardSourceLocker"]
        ),
        // CLT-only machines lack a working XCTest/Swift Testing runner.
        // CoreTestRunner is the verified red→green entrypoint: `swift run CoreTestRunner`
        .executableTarget(
            name: "CoreTestRunner",
            dependencies: ["KeyboardSourceLocker"],
            path: "Tests/CoreTestRunner"
        ),
    ],
    swiftLanguageModes: [.v6]
)
