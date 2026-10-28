import Foundation

public enum AppVersion {
    private struct PackageManifest: Decodable {
        let version: String
    }

    /// Last-resort value when neither `package.json` nor Info.plist is available.
    public static let emergencyFallback = "0.0.0"

    public static func version(fromPackageJSON data: Data) throws -> String {
        let manifest = try JSONDecoder().decode(PackageManifest.self, from: data)
        let version = manifest.version.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !version.isEmpty else {
            throw AppVersionError.emptyVersion
        }
        return version
    }

    public static func version(fromPackageJSONAt url: URL) throws -> String {
        let data = try Data(contentsOf: url)
        return try version(fromPackageJSON: data)
    }

    /// Prefer an explicit package.json version, then Info.plist, then emergency fallback.
    public static func shortVersion(packageJSONVersion: String?, bundleShortVersion: String?) -> String {
        let fromJSON = packageJSONVersion?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !fromJSON.isEmpty { return fromJSON }

        let fromBundle = bundleShortVersion?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !fromBundle.isEmpty { return fromBundle }

        return emergencyFallback
    }

    public static func display(shortVersion: String, bundleBuild: String?) -> String {
        let version = shortVersion.trimmingCharacters(in: .whitespacesAndNewlines)
        let resolved = version.isEmpty ? emergencyFallback : version
        let build = bundleBuild?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !build.isEmpty, build != resolved {
            return "\(resolved) (\(build))"
        }
        return resolved
    }

    public static func menuTitle(shortVersion: String, bundleBuild: String?) -> String {
        "Version \(display(shortVersion: shortVersion, bundleBuild: bundleBuild))"
    }

    public static func findPackageJSON(
        startingAt directory: URL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath),
        bundle: Bundle = .main,
        fileManager: FileManager = .default
    ) -> URL? {
        if let bundled = bundle.url(forResource: "package", withExtension: "json") {
            return bundled
        }

        var dir = directory.standardizedFileURL
        for _ in 0..<8 {
            let candidate = dir.appendingPathComponent("package.json")
            if fileManager.fileExists(atPath: candidate.path) {
                return candidate
            }
            let parent = dir.deletingLastPathComponent()
            if parent.path == dir.path { break }
            dir = parent
        }
        return nil
    }

    public static func loadPackageJSONVersion(
        startingAt directory: URL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath),
        bundle: Bundle = .main
    ) -> String? {
        guard let url = findPackageJSON(startingAt: directory, bundle: bundle) else { return nil }
        return try? version(fromPackageJSONAt: url)
    }

    public static func currentMenuTitle(bundle: Bundle = .main) -> String {
        let info = bundle.infoDictionary
        let short = shortVersion(
            packageJSONVersion: loadPackageJSONVersion(bundle: bundle),
            bundleShortVersion: info?["CFBundleShortVersionString"] as? String
        )
        return menuTitle(
            shortVersion: short,
            bundleBuild: info?["CFBundleVersion"] as? String
        )
    }
}

public enum AppVersionError: Error, Equatable, Sendable {
    case emptyVersion
}
