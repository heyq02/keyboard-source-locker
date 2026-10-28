public enum InputSourceCategory: Equatable, Sendable {
    case keyboard
    case palette
    case other
}

public struct InputSourceRecord: Equatable, Sendable {
    public let id: InputSourceID
    public let displayName: String
    public let category: InputSourceCategory
    public let isSelectCapable: Bool

    public init(
        id: InputSourceID,
        displayName: String,
        category: InputSourceCategory,
        isSelectCapable: Bool
    ) {
        self.id = id
        self.displayName = displayName
        self.category = category
        self.isSelectCapable = isSelectCapable
    }

    public var asInputSource: InputSource {
        InputSource(id: id, displayName: displayName)
    }
}

public enum SelectableInputSources {
    /// Keep sources a user can meaningfully lock to in the menu bar picker.
    public static func filter(_ records: [InputSourceRecord]) -> [InputSource] {
        records
            .filter { $0.category == .keyboard && $0.isSelectCapable }
            .map(\.asInputSource)
    }
}
