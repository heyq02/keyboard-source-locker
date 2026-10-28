import Foundation
import ServiceManagement

/// Abstraction over `SMAppService.mainApp` so registration failures can be unit-tested.
public protocol SMAppServiceControlling: AnyObject {
    var status: SMAppService.Status { get }
    func register() throws
    func unregister() throws
}

public final class SystemSMAppService: SMAppServiceControlling {
    public init() {}

    public var status: SMAppService.Status { SMAppService.mainApp.status }

    public func register() throws {
        try SMAppService.mainApp.register()
    }

    public func unregister() throws {
        try SMAppService.mainApp.unregister()
    }
}

/// Production Launch-at-Login adapter using `SMAppService` (macOS 13+).
public final class SMAppServiceLaunchAtLogin: LaunchAtLoginServing {
    private let service: any SMAppServiceControlling

    public init(service: any SMAppServiceControlling = SystemSMAppService()) {
        self.service = service
    }

    public var isEnabled: Bool {
        service.status == .enabled
    }

    public func setEnabled(_ enabled: Bool) throws {
        do {
            if enabled {
                try service.register()
            } else {
                try service.unregister()
            }
        } catch {
            throw LaunchAtLoginError.registrationFailed(
                LaunchAtLoginHints.message(
                    status: service.status,
                    underlyingDescription: error.localizedDescription
                )
            )
        }
    }
}

/// Maps `SMAppService.Status` to a user-facing registration failure hint.
public enum LaunchAtLoginHints {
    public static func message(
        status: SMAppService.Status,
        underlyingDescription: String
    ) -> String {
        switch status {
        case .requiresApproval:
            return "Open System Settings → General → Login Items and allow Keyboard Source Locker."
        case .notFound:
            return "Install KeyboardSourceLocker.app (for example via `vp run package`) before enabling Launch at Login."
        case .enabled, .notRegistered:
            return underlyingDescription
        @unknown default:
            return underlyingDescription
        }
    }
}
