public enum LaunchAtLoginError: Error, Equatable, Sendable {
    case registrationFailed(String)

    public var message: String {
        switch self {
        case .registrationFailed(let detail):
            return detail
        }
    }
}

public protocol LaunchAtLoginServing: AnyObject {
    var isEnabled: Bool { get }
    func setEnabled(_ enabled: Bool) throws
}

public final class LaunchAtLoginController {
    private let service: any LaunchAtLoginServing
    public private(set) var lastErrorDescription: String?

    public init(service: any LaunchAtLoginServing) {
        self.service = service
    }

    public var isEnabled: Bool { service.isEnabled }

    @discardableResult
    public func setEnabled(_ enabled: Bool) -> Bool {
        do {
            try service.setEnabled(enabled)
            lastErrorDescription = nil
            return true
        } catch let error as LaunchAtLoginError {
            lastErrorDescription = error.message
            return false
        } catch {
            lastErrorDescription = error.localizedDescription
            return false
        }
    }
}
