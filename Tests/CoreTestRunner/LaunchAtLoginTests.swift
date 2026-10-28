import KeyboardSourceLocker

enum LaunchAtLoginTests {
    static func run() {
        print("LaunchAtLogin")
        reportsDisabledByDefault()
        enablesAndDisables()
        surfacesRegisterFailure()
    }

    private static func reportsDisabledByDefault() {
        let service = FakeLaunchAtLoginService(isEnabled: false)
        let controller = LaunchAtLoginController(service: service)
        Expect.equal(controller.isEnabled, false, "reports disabled by default")
    }

    private static func enablesAndDisables() {
        let service = FakeLaunchAtLoginService(isEnabled: false)
        let controller = LaunchAtLoginController(service: service)

        let enabled = controller.setEnabled(true)
        Expect.equal(enabled, true, "enable succeeds")
        Expect.equal(controller.isEnabled, true, "reports enabled after set")
        Expect.equal(service.isEnabled, true, "service enabled after set")

        let disabled = controller.setEnabled(false)
        Expect.equal(disabled, true, "disable succeeds")
        Expect.equal(controller.isEnabled, false, "reports disabled after clear")
    }

    private static func surfacesRegisterFailure() {
        let service = FakeLaunchAtLoginService(isEnabled: false, shouldFail: true)
        let controller = LaunchAtLoginController(service: service)

        let ok = controller.setEnabled(true)
        Expect.equal(ok, false, "surfaces register failure")
        Expect.equal(controller.isEnabled, false, "stays disabled after failure")
        Expect.true(controller.lastErrorDescription != nil, "keeps last error description")
    }
}

final class FakeLaunchAtLoginService: LaunchAtLoginServing {
    var isEnabled: Bool
    var shouldFail: Bool
    private(set) var setCalls: [Bool] = []

    init(isEnabled: Bool, shouldFail: Bool = false) {
        self.isEnabled = isEnabled
        self.shouldFail = shouldFail
    }

    func setEnabled(_ enabled: Bool) throws {
        setCalls.append(enabled)
        if shouldFail {
            throw LaunchAtLoginError.registrationFailed("not allowed in tests")
        }
        isEnabled = enabled
    }
}
