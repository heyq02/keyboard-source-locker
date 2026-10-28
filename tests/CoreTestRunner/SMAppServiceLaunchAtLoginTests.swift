import Foundation
import KeyboardSourceLocker
import ServiceManagement

enum SMAppServiceLaunchAtLoginTests {
    static func run() {
        print("SMAppServiceLaunchAtLogin")
        hintMessagesForKnownStatuses()
        readsEnabledFlagFromInjectedService()
        registerSuccessPath()
        unregisterSuccessPath()
        registerFailureUsesNotFoundHint()
        unregisterFailureUsesUnderlyingDescription()
        systemAdapterReadable()
    }

    private static func hintMessagesForKnownStatuses() {
        Expect.equal(
            LaunchAtLoginHints.message(status: .requiresApproval, underlyingDescription: "x"),
            "Open System Settings → General → Login Items and allow Keyboard Source Locker.",
            "requiresApproval hint"
        )
        Expect.equal(
            LaunchAtLoginHints.message(status: .notFound, underlyingDescription: "x"),
            "Install KeyboardSourceLocker.app (for example via `vp run package`) before enabling Launch at Login.",
            "notFound hint"
        )
        Expect.equal(
            LaunchAtLoginHints.message(status: .enabled, underlyingDescription: "boom"),
            "boom",
            "enabled uses underlying description"
        )
        Expect.equal(
            LaunchAtLoginHints.message(status: .notRegistered, underlyingDescription: "boom"),
            "boom",
            "notRegistered uses underlying description"
        )
    }

    private static func readsEnabledFlagFromInjectedService() {
        let fake = FakeSMAppService(status: .enabled)
        let service = SMAppServiceLaunchAtLogin(service: fake)
        Expect.equal(service.isEnabled, true, "isEnabled true when status is enabled")

        fake.status = .notRegistered
        Expect.equal(service.isEnabled, false, "isEnabled false when status is notRegistered")
    }

    private static func registerSuccessPath() {
        let fake = FakeSMAppService(status: .notRegistered)
        let service = SMAppServiceLaunchAtLogin(service: fake)
        do {
            try service.setEnabled(true)
            Expect.equal(fake.registerCalls, 1, "register success calls register once")
            Expect.equal(fake.status, .enabled, "register success flips status to enabled")
        } catch {
            Expect.true(false, "register success should not throw: \(error)")
        }
    }

    private static func unregisterSuccessPath() {
        let fake = FakeSMAppService(status: .enabled)
        let service = SMAppServiceLaunchAtLogin(service: fake)
        do {
            try service.setEnabled(false)
            Expect.equal(fake.unregisterCalls, 1, "unregister success calls unregister once")
            Expect.equal(fake.status, .notRegistered, "unregister success flips status to notRegistered")
        } catch {
            Expect.true(false, "unregister success should not throw: \(error)")
        }
    }

    private static func registerFailureUsesNotFoundHint() {
        let fake = FakeSMAppService(status: .notFound, registerError: "denied")
        let service = SMAppServiceLaunchAtLogin(service: fake)
        do {
            try service.setEnabled(true)
            Expect.true(false, "expected register failure")
        } catch let error as LaunchAtLoginError {
            Expect.equal(
                error.message,
                "Install KeyboardSourceLocker.app (for example via `vp run package`) before enabling Launch at Login.",
                "register failure uses notFound hint"
            )
        } catch {
            Expect.true(false, "expected LaunchAtLoginError, got \(error)")
        }
    }

    private static func unregisterFailureUsesUnderlyingDescription() {
        let fake = FakeSMAppService(status: .enabled, unregisterError: "cannot unregister")
        let service = SMAppServiceLaunchAtLogin(service: fake)
        do {
            try service.setEnabled(false)
            Expect.true(false, "expected unregister failure")
        } catch let error as LaunchAtLoginError {
            Expect.equal(error.message, "cannot unregister", "unregister failure uses underlying description")
        } catch {
            Expect.true(false, "expected LaunchAtLoginError, got \(error)")
        }
    }

    private static func systemAdapterReadable() {
        let adapter = SystemSMAppService()
        _ = adapter.status
        // Outside a packaged .app these calls typically fail; still exercise the wrappers.
        _ = try? adapter.register()
        _ = try? adapter.unregister()
        Expect.true(true, "SystemSMAppService methods are callable")
    }
}

final class FakeSMAppService: SMAppServiceControlling {
    var status: SMAppService.Status
    var registerError: String?
    var unregisterError: String?
    private(set) var registerCalls = 0
    private(set) var unregisterCalls = 0

    init(
        status: SMAppService.Status,
        registerError: String? = nil,
        unregisterError: String? = nil
    ) {
        self.status = status
        self.registerError = registerError
        self.unregisterError = unregisterError
    }

    func register() throws {
        registerCalls += 1
        if let registerError {
            throw NSError(domain: "KeyboardSourceLockerTests", code: 1, userInfo: [
                NSLocalizedDescriptionKey: registerError,
            ])
        }
        status = .enabled
    }

    func unregister() throws {
        unregisterCalls += 1
        if let unregisterError {
            throw NSError(domain: "KeyboardSourceLockerTests", code: 2, userInfo: [
                NSLocalizedDescriptionKey: unregisterError,
            ])
        }
        status = .notRegistered
    }
}
