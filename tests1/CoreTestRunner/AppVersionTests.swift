import Foundation
import KeyboardSourceLocker

enum AppVersionTests {
    static func run() {
        print("AppVersion")
        parsesVersionFromPackageJSON()
        rejectsEmptyVersionInPackageJSON()
        prefersPackageJSONOverBundle()
        usesBundleWhenPackageJSONMissing()
        fallsBackWhenBothMissing()
        trimsWhitespacePackageVersion()
        includesBuildWhenDifferent()
        omitsBuildWhenSameAsShortVersion()
        emptyShortVersionUsesEmergencyFallback()
        menuTitlePrefixesVersion()
        findsPackageJSONInRepoRoot()
        findsPackageJSONFromNestedDirectory()
        returnsNilWhenPackageJSONMissingNearby()
        loadPackageJSONVersionFromRepo()
        currentMenuTitleNonEmpty()
        versionFromMissingFileThrows()
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

    private static func fallsBackWhenBothMissing() {
        let short = AppVersion.shortVersion(packageJSONVersion: nil, bundleShortVersion: nil)
        Expect.equal(short, AppVersion.emergencyFallback, "falls back when both missing")
    }

    private static func trimsWhitespacePackageVersion() {
        let short = AppVersion.shortVersion(
            packageJSONVersion: "   ",
            bundleShortVersion: "1.0.0"
        )
        Expect.equal(short, "1.0.0", "whitespace package version falls through to bundle")
    }

    private static func includesBuildWhenDifferent() {
        let text = AppVersion.display(shortVersion: "0.0.4", bundleBuild: "42")
        Expect.equal(text, "0.0.4 (42)", "includes build when different from short version")
    }

    private static func omitsBuildWhenSameAsShortVersion() {
        let text = AppVersion.display(shortVersion: "0.0.4", bundleBuild: "0.0.4")
        Expect.equal(text, "0.0.4", "omits build when same as short version")
    }

    private static func emptyShortVersionUsesEmergencyFallback() {
        let text = AppVersion.display(shortVersion: "  ", bundleBuild: nil)
        Expect.equal(text, AppVersion.emergencyFallback, "empty short version uses emergency fallback")
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

    private static func findsPackageJSONFromNestedDirectory() {
        let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        let nested = root.appendingPathComponent("tests1/CoreTestRunner")
        let url = AppVersion.findPackageJSON(startingAt: nested)
        Expect.true(url != nil, "walks parents to find package.json")
    }

    private static func returnsNilWhenPackageJSONMissingNearby() {
        let temp = FileManager.default.temporaryDirectory
            .appendingPathComponent("ksl-no-package-\(UUID().uuidString)", isDirectory: true)
        try? FileManager.default.createDirectory(at: temp, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: temp) }

        // Start deep enough that walking 8 parents stays under /tmp or similar without hitting the repo.
        var deep = temp
        for i in 0..<6 {
            deep = deep.appendingPathComponent("d\(i)", isDirectory: true)
        }
        try? FileManager.default.createDirectory(at: deep, withIntermediateDirectories: true)

        let url = AppVersion.findPackageJSON(startingAt: deep, bundle: Bundle(for: BundleToken.self))
        Expect.true(url == nil, "returns nil when package.json is not nearby")
    }

    private static func loadPackageJSONVersionFromRepo() {
        let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        let version = AppVersion.loadPackageJSONVersion(startingAt: root, bundle: Bundle(for: BundleToken.self))
        Expect.true(version?.isEmpty == false, "loadPackageJSONVersion reads repo package.json")
    }

    private static func currentMenuTitleNonEmpty() {
        let title = AppVersion.currentMenuTitle(bundle: Bundle(for: BundleToken.self))
        Expect.true(title.hasPrefix("Version "), "currentMenuTitle prefixes Version")
        Expect.true(title.count > "Version ".count, "currentMenuTitle includes a version")
    }

    private static func versionFromMissingFileThrows() {
        let missing = FileManager.default.temporaryDirectory
            .appendingPathComponent("missing-package-\(UUID().uuidString).json")
        var threw = false
        do {
            _ = try AppVersion.version(fromPackageJSONAt: missing)
        } catch {
            threw = true
        }
        Expect.true(threw, "version(fromPackageJSONAt:) throws for missing file")
    }
}

private final class BundleToken: NSObject {}
