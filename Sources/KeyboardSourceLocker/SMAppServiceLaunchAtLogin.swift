import Foundation
import ServiceManagement

/// Production Launch-at-Login adapter using `SMAppService` (macOS 13+).
public final class SMAppServiceLaunchAtLogin: LaunchAtLoginServing {
    public init() {}

    public var isEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }

    public func setEnabled(_ enabled: Bool) throws {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            let status = SMAppService.mainApp.status
            let hint: String
            switch status {
            case .requiresApproval:
                hint = "Open System Settings → General → Login Items and allow Keyboard Source Locker."
            case .notFound:
                hint = "Install KeyboardSourceLocker.app (for example via `vp run package`) before enabling Launch at Login."
            case .enabled, .notRegistered:
                hint = error.localizedDescription
            @unknown default:
                hint = error.localizedDescription
            }
            throw LaunchAtLoginError.registrationFailed(hint)
        }
    }
}
