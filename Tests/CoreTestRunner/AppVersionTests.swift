import KeyboardSourceLocker

enum AppVersionTests {
    static func run() {
        print("AppVersion")
        usesBundleShortVersionWhenPresent()
        fallsBackWhenBundleVersionMissing()
        fallsBackWhenBundleVersionBlank()
        includesBuildWhenDifferent()
        omitsBuildWhenSameAsShortVersion()
        menuTitlePrefixesVersion()
    }

    private static func usesBundleShortVersionWhenPresent() {
        let text = AppVersion.display(bundleShortVersion: "0.0.2", bundleBuild: nil)
        Expect.equal(text, "0.0.2", "uses bundle short version when present")
    }

    private static func fallsBackWhenBundleVersionMissing() {
        let text = AppVersion.display(bundleShortVersion: nil, bundleBuild: nil)
        Expect.equal(text, AppVersion.fallback, "falls back when bundle version missing")
    }

    private static func fallsBackWhenBundleVersionBlank() {
        let text = AppVersion.display(bundleShortVersion: "  ", bundleBuild: nil)
        Expect.equal(text, AppVersion.fallback, "falls back when bundle version blank")
    }

    private static func includesBuildWhenDifferent() {
        let text = AppVersion.display(bundleShortVersion: "0.0.2", bundleBuild: "42")
        Expect.equal(text, "0.0.2 (42)", "includes build when different from short version")
    }

    private static func omitsBuildWhenSameAsShortVersion() {
        let text = AppVersion.display(bundleShortVersion: "0.0.2", bundleBuild: "0.0.2")
        Expect.equal(text, "0.0.2", "omits build when same as short version")
    }

    private static func menuTitlePrefixesVersion() {
        let text = AppVersion.menuTitle(bundleShortVersion: "0.0.2", bundleBuild: nil)
        Expect.equal(text, "Version 0.0.2", "menu title prefixes Version")
    }
}
