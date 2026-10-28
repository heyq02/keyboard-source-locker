import KeyboardSourceLocker

final class FakeInputSourceCatalog: InputSourceCatalog {
    private(set) var sources: [InputSource]
    private(set) var activeID: InputSourceID?
    private(set) var selectedHistory: [InputSourceID] = []
    private var handler: ((InputSourceID) -> Void)?

    init(sources: [InputSource], activeID: InputSourceID?) {
        self.sources = sources
        self.activeID = activeID
    }

    func installedSources() -> [InputSource] { sources }

    func activeSourceID() -> InputSourceID? { activeID }

    func selectSource(id: InputSourceID) -> Bool {
        guard sources.contains(where: { $0.id == id }) else { return false }
        selectedHistory.append(id)
        activeID = id
        return true
    }

    func setActiveSourceChangeHandler(_ handler: ((InputSourceID) -> Void)?) {
        self.handler = handler
    }

    func simulateSystemSwitch(to id: InputSourceID) {
        activeID = id
        handler?(id)
    }
}
