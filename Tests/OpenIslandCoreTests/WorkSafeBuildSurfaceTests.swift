import XCTest

final class WorkSafeBuildSurfaceTests: XCTestCase {
    private var repositoryRoot: URL {
        URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    }

    func testPackageDoesNotCompileNetworkUpdateOrNonApprovedAgentIntegrations() throws {
        let package = try contents("Package.swift")

        XCTAssertFalse(package.contains("Sparkle"), "Work-safe build must not compile Sparkle auto-update support.")
        XCTAssertFalse(package.contains("swift-markdown-ui"), "Work-safe build should avoid external UI dependencies that are not needed for Codex/Claude monitoring.")
    }

    func testMacAppEntitlementsDoNotRequestNetworkClientAccess() throws {
        let entitlements = try contents("config/packaging/OpenIslandApp.entitlements")

        XCTAssertFalse(entitlements.contains("com.apple.security.network.client"), "Work-safe macOS app must not request generic outbound network access.")
    }

    func testRemovedRuntimeSurfacesStayOutOfTheBuild() throws {
        let package = try contents("Package.swift")
        let appModel = try contents("Sources/OpenIslandApp/AppModel.swift")
        let settingsView = try contents("Sources/OpenIslandApp/Views/SettingsView.swift")
        let hookCoordinator = try contents("Sources/OpenIslandApp/HookInstallationCoordinator.swift")
        let hookCLI = try contents("Sources/OpenIslandHooks/OpenIslandHooksCLI.swift")

        XCTAssertTrue(package.contains(#""WatchHTTPEndpoint.swift""#), "Watch/LAN endpoint must be explicitly excluded from the target.")
        XCTAssertTrue(package.contains(#""WatchNotificationRelay.swift""#), "Watch/LAN relay must be explicitly excluded from the target.")
        XCTAssertTrue(package.contains(#""Resources/open-island-opencode.js""#), "OpenCode plugin resource must be explicitly excluded from the target.")
        XCTAssertTrue(package.contains(#""UpdateChecker.swift""#), "Sparkle update checker must be explicitly excluded from the target.")
        XCTAssertTrue(package.contains(#""OpenCodePluginInstallationManager.swift""#), "OpenCode installer source must be explicitly excluded from the target.")
        XCTAssertTrue(package.contains(#""CursorHookInstallationManager.swift""#), "Cursor installer source must be explicitly excluded from the target.")
        XCTAssertTrue(package.contains(#""CursorHookInstaller.swift""#), "Cursor hook installer source must be explicitly excluded from the target.")
        XCTAssertTrue(package.contains(#""GeminiHookInstallationManager.swift""#), "Gemini installer source must be explicitly excluded from the target.")
        XCTAssertTrue(package.contains(#""GeminiHookInstaller.swift""#), "Gemini hook installer source must be explicitly excluded from the target.")
        XCTAssertTrue(package.contains(#""KimiHookInstallationManager.swift""#), "Kimi installer source must be explicitly excluded from the target.")
        XCTAssertTrue(package.contains(#""KimiHookInstaller.swift""#), "Kimi hook installer source must be explicitly excluded from the target.")

        XCTAssertFalse(appModel.contains("WatchNotificationRelay"), "Watch/LAN relay must not be reachable from AppModel.")
        XCTAssertFalse(appModel.contains("updateChecker"), "Network update checks must not run at startup.")
        XCTAssertFalse(appModel.contains("scheduleOpenCodeSessionPersistence"), "OpenCode session persistence must not run in the work-safe app.")
        XCTAssertFalse(appModel.contains("scheduleCursorSessionPersistence"), "Cursor session persistence must not run in the work-safe app.")
        XCTAssertTrue(settingsView.contains("https://github.com/kamegg13/open-vibe-island/releases/latest"), "Manual update checks must point at the user's fork.")
        XCTAssertFalse(settingsView.contains("https://github.com/Octane0411/open-vibe-island/releases/latest"), "Manual update checks must not point at the upstream repository.")
        XCTAssertFalse(settingsView.contains("OpenCode"), "Setup UI must not expose OpenCode in the work-safe app.")
        XCTAssertFalse(settingsView.contains("Qoder"), "Setup UI must not expose Qoder in the work-safe app.")
        XCTAssertFalse(settingsView.contains("Qwen Code"), "Setup UI must not expose Qwen Code in the work-safe app.")
        XCTAssertFalse(settingsView.contains("Factory"), "Setup UI must not expose Factory in the work-safe app.")
        XCTAssertFalse(settingsView.contains("CodeBuddy"), "Setup UI must not expose CodeBuddy in the work-safe app.")
        XCTAssertFalse(settingsView.contains("Cursor"), "Setup UI must not expose Cursor in the work-safe app.")
        XCTAssertFalse(settingsView.contains("Gemini"), "Setup UI must not expose Gemini in the work-safe app.")
        XCTAssertFalse(settingsView.contains("Kimi"), "Setup UI must not expose Kimi in the work-safe app.")
        XCTAssertFalse(hookCoordinator.contains("OpenCodePluginInstallationManager"), "OpenCode plugin installer must not be reachable.")
        XCTAssertFalse(hookCoordinator.contains("CursorHookInstallationManager"), "Cursor hook installer must not be reachable.")
        XCTAssertFalse(hookCoordinator.contains("GeminiHookInstallationManager"), "Gemini hook installer must not be reachable.")
        XCTAssertFalse(hookCoordinator.contains("KimiHookInstallationManager"), "Kimi hook installer must not be reachable.")
        XCTAssertTrue(hookCoordinator.contains("installAsWrapper()"), "Claude Usage Bridge install must preserve existing custom statusLine commands.")
        XCTAssertTrue(hookCoordinator.contains("existingStatusLineConflict"), "Claude Usage Bridge install must fall back to wrapper mode on custom statusLine conflicts.")
        XCTAssertFalse(hookCLI.contains("case cursor"), "Hook helper must not accept Cursor events in the work-safe app.")
        XCTAssertFalse(hookCLI.contains("case gemini"), "Hook helper must not accept Gemini events in the work-safe app.")
        XCTAssertFalse(hookCLI.contains("case kimi"), "Hook helper must not accept Kimi events in the work-safe app.")
        XCTAssertFalse(hookCLI.contains("case qoder"), "Hook helper must not accept Qoder events in the work-safe app.")
        XCTAssertFalse(hookCLI.contains("case qwen"), "Hook helper must not accept Qwen events in the work-safe app.")
        XCTAssertFalse(hookCLI.contains("case factory"), "Hook helper must not accept Factory events in the work-safe app.")
        XCTAssertFalse(hookCLI.contains("case codebuddy"), "Hook helper must not accept CodeBuddy events in the work-safe app.")
    }

    func testIslandChromeUsesTrueBlackAndCodexAppServerFallsBackToAllThreads() throws {
        let v6Palette = try contents("Sources/OpenIslandApp/V6ClosedPillShape.swift")
        let codexAppServerCoordinator = try contents("Sources/OpenIslandApp/CodexAppServerCoordinator.swift")

        XCTAssertTrue(v6Palette.contains("static let ink = Color.black"), "The island ink must be true black so it blends with the physical notch.")
        XCTAssertTrue(codexAppServerCoordinator.contains("listThreads(limit:"), "Codex app-server sync must fall back to the full thread list when loaded threads are empty.")
    }

    func testAppcastDoesNotPointAtUpstreamReleases() throws {
        let appcast = try contents("appcast.xml")

        XCTAssertTrue(appcast.contains("https://github.com/kamegg13/open-vibe-island/releases"), "Appcast metadata must point at the fork.")
        XCTAssertFalse(appcast.contains("Octane0411/open-vibe-island"), "Appcast must not retain upstream release URLs.")
    }

    private func contents(_ relativePath: String) throws -> String {
        let url = repositoryRoot.appendingPathComponent(relativePath)
        return try String(contentsOf: url, encoding: .utf8)
    }
}
