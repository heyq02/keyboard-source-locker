import Foundation

public enum AppVersion {
    /// Keep in sync with `Resources/Info.plist` CFBundleShortVersionString for `swift run` builds.
    public static let fallback = "0.0.2"

    public static func display(bundleShortVersion: String?, bundleBuild: String?) -> String {
        let short = bundleShortVersion?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let version = short.isEmpty ? fallback : short

        let build = bundleBuild?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !build.isEmpty, build != version {
            return "\(version) (\(build))"
        }
        return version
    }

    public static func menuTitle(bundleShortVersion: String?, bundleBuild: String?) -> String {
        "Version \(display(bundleShortVersion: bundleShortVersion, bundleBuild: bundleBuild))"
    }

    public static func currentMenuTitle(bundle: Bundle = .main) -> String {
        let info = bundle.infoDictionary
        return menuTitle(
            bundleShortVersion: info?["CFBundleShortVersionString"] as? String,
            bundleBuild: info?["CFBundleVersion"] as? String
        )
    }
}
