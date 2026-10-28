public struct InputSource: Equatable, Sendable, Identifiable {
    public let id: InputSourceID
    public let displayName: String

    public init(id: InputSourceID, displayName: String) {
        self.id = id
        self.displayName = displayName
    }
}

/// Input-source access seam. Main-actor isolated because the production adapter
/// (`TISInputSourceCatalog`) must be driven from the main thread.
@MainActor
public protocol InputSourceCatalog: AnyObject {
    func installedSources() -> [InputSource]
    func activeSourceID() -> InputSourceID?
    @discardableResult
    func selectSource(id: InputSourceID) -> Bool
    func setActiveSourceChangeHandler(_ handler: ((InputSourceID) -> Void)?)
}
