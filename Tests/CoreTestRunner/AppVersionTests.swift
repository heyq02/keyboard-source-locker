import Foundation
import KeyboardSourceLocker

enum AppVersionTests {
    static func run() {
        print("AppVersion")
        parsesVersionFromPackageJSON()
        rejectsEmptyVersionInPackageJSON()
        prefersPackageJSONOverBundle()
        usesBundleWhenPackageJSONMissing()
        includesBuildWhenDifferent()
        omitsBuildWhenSameAsShortVersion()
        menuTitlePrefixesVersion()
        findsPackageJSONInRepoRoot()
    }

    private static func parsesVersionFromPackageJSON() {
        let json = Data(#"{"name":"keyboard-source-locker","version":"0.0.4"}"#.utf8)
        let version = try? AppVersion.version(fromPackageJSON: json)
        Expect.equal(version, "0.0.4", "parses version from package.json")
    }

    private static func rejectsEmptyVersionInPackageJSON() {
        let json = Data(#"{"version":"  "}"#.utf8)
        var threw = false
        do {
            _ = try AppVersion.version(fromPackageJSON: json)
        } catch AppVersionError.emptyVersion {
            threw = true
        } catch {
            threw = false
        }
        Expect.true(threw, "rejects empty version in package.json")
    }

    private static func prefersPackageJSONOverBundle() {
        let short = AppVersion.shortVersion(
            packageJSONVersion: "1.2.3",
            bundleShortVersion: "9.9.9"
        )
        Expect.equal(short, "1.2.3", "prefers package.json over bundle version")
    }

    private static func usesBundleWhenPackageJSONMissing() {
        let short = AppVersion.shortVersion(
            packageJSONVersion: nil,
            bundleShortVersion: "0.0.4"
        )
        Expect.equal(short, "0.0.4", "uses bundle when package.json missing")
    }

    private static func includesBuildWhenDifferent() {
        let text = AppVersion.display(shortVersion: "0.0.4", bundleBuild: "42")
        Expect.equal(text, "0.0.4 (42)", "includes build when different from short version")
    }

    private static func omitsBuildWhenSameAsShortVersion() {
        let text = AppVersion.display(shortVersion: "0.0.4", bundleBuild: "0.0.4")
        Expect.equal(text, "0.0.4", "omits build when same as short version")
    }

    private static func menuTitlePrefixesVersion() {
        let text = AppVersion.menuTitle(shortVersion: "0.0.4", bundleBuild: nil)
        Expect.equal(text, "Version 0.0.4", "menu title prefixes Version")
    }

    private static func findsPackageJSONInRepoRoot() {
        let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        let url = AppVersion.findPackageJSON(startingAt: root)
        Expect.true(url != nil, "finds package.json from repo root")
        if let url {
            let version = try? AppVersion.version(fromPackageJSONAt: url)
            Expect.true(version?.isEmpty == false, "reads non-empty version from repo package.json")
        }
    }
}
