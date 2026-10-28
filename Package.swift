// swift-tools-version: 6.2

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
        .executable(
            name: "VersionTool",
            targets: ["VersionTool"]
        ),
    ],
    targets: [
        .target(
            name: "KeyboardSourceLocker",
            path: "src/KeyboardSourceLocker",
            linkerSettings: [
                .linkedFramework("Carbon"),
                .linkedFramework("ServiceManagement"),
            ]
        ),
        .executableTarget(
            name: "KeyboardSourceLockerApp",
            dependencies: ["KeyboardSourceLocker"],
            path: "src/KeyboardSourceLockerApp"
        ),
        .executableTarget(
            name: "VersionTool",
            dependencies: ["KeyboardSourceLocker"],
            path: "src/VersionTool"
        ),
        // CLT-only machines lack a working XCTest/Swift Testing runner.
        // CoreTestRunner is the verified red→green entrypoint: `swift run CoreTestRunner`
        .executableTarget(
            name: "CoreTestRunner",
            dependencies: ["KeyboardSourceLocker"],
            path: "tests1/CoreTestRunner"
        ),
    ],
    swiftLanguageModes: [.v6]
)
