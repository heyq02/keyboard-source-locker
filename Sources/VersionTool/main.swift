import Foundation
import KeyboardSourceLocker

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
guard let url = AppVersion.findPackageJSON(startingAt: root) else {
    fputs("error: package.json not found (version source of truth)\n", stderr)
    exit(1)
}

do {
    let version = try AppVersion.version(fromPackageJSONAt: url)
    print(version)
} catch {
    fputs("error: failed to read version from \(url.path): \(error)\n", stderr)
    exit(1)
}
