// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "OpenIsland",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
    ],
    products: [
        .library(
            name: "OpenIslandCore",
            targets: ["OpenIslandCore"]
        ),
        .executable(
            name: "OpenIslandHooks",
            targets: ["OpenIslandHooks"]
        ),
        .executable(
            name: "OpenIslandSetup",
            targets: ["OpenIslandSetup"]
        ),
        .executable(
            name: "OpenIslandApp",
            targets: ["OpenIslandApp"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "OpenIslandCore",
            exclude: [
                "CursorHookInstallationManager.swift",
                "CursorHookInstaller.swift",
                "GeminiHookInstallationManager.swift",
                "GeminiHookInstaller.swift",
                "KimiHookInstallationManager.swift",
                "KimiHookInstaller.swift",
                "OpenCodePluginInstallationManager.swift",
                "WatchHTTPEndpoint.swift",
                "WatchNotificationRelay.swift",
            ]
        ),
        .executableTarget(
            name: "OpenIslandHooks",
            dependencies: ["OpenIslandCore"]
        ),
        .executableTarget(
            name: "OpenIslandSetup",
            dependencies: ["OpenIslandCore"]
        ),
        .executableTarget(
            name: "OpenIslandApp",
            dependencies: [
                "OpenIslandCore",
            ],
            exclude: [
                "UpdateChecker.swift",
                "Resources/open-island-opencode.js",
            ],
            resources: [
                .process("Resources"),
            ]
        ),
        .testTarget(
            name: "OpenIslandCoreTests",
            dependencies: ["OpenIslandCore"],
            exclude: [
                "CursorHooksTests.swift",
                "GeminiHooksTests.swift",
                "KimiHooksTests.swift",
                "WatchNotificationRelayTests.swift",
            ]
        ),
        .testTarget(
            name: "OpenIslandAppTests",
            dependencies: ["OpenIslandApp", "OpenIslandCore"]
        ),
    ]
)
