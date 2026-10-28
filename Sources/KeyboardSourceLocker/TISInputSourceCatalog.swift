import Carbon
import Foundation

/// Production adapter over Text Input Source (TIS) APIs.
/// Observes input-source changes on the main queue via a selector (avoids Sendable closure captures).
public final class TISInputSourceCatalog: NSObject, InputSourceCatalog {
    private var isObserving = false
    private var handler: ((InputSourceID) -> Void)?

    public override init() {
        super.init()
    }

    deinit {
        stopObserving()
    }

    public func installedSources() -> [InputSource] {
        SelectableInputSources.filter(allRecords())
    }

    public func activeSourceID() -> InputSourceID? {
        guard let source = TISCopyCurrentKeyboardInputSource()?.takeRetainedValue() else { return nil }
        guard let id = stringProperty(source, kTISPropertyInputSourceID) else { return nil }
        return InputSourceID(id)
    }

    @discardableResult
    public func selectSource(id: InputSourceID) -> Bool {
        guard let source = findSource(id: id) else { return false }
        let status = TISSelectInputSource(source)
        return status == noErr
    }

    public func setActiveSourceChangeHandler(_ handler: ((InputSourceID) -> Void)?) {
        self.handler = handler
        if handler != nil {
            startObserving()
        } else {
            stopObserving()
        }
    }

    private func allRecords() -> [InputSourceRecord] {
        guard let list = TISCreateInputSourceList(nil, false)?.takeRetainedValue() as? [TISInputSource] else {
            return []
        }
        return list.compactMap(record(from:))
    }

    private func record(from source: TISInputSource) -> InputSourceRecord? {
        guard let id = stringProperty(source, kTISPropertyInputSourceID) else { return nil }
        let name = stringProperty(source, kTISPropertyLocalizedName) ?? id
        let category = category(from: stringProperty(source, kTISPropertyInputSourceCategory))
        let selectCapable = boolProperty(source, kTISPropertyInputSourceIsSelectCapable) ?? false
        return InputSourceRecord(
            id: InputSourceID(id),
            displayName: name,
            category: category,
            isSelectCapable: selectCapable
        )
    }

    private func category(from raw: String?) -> InputSourceCategory {
        switch raw {
        case String(kTISCategoryKeyboardInputSource):
            return .keyboard
        case String(kTISCategoryPaletteInputSource):
            return .palette
        default:
            return .other
        }
    }

    private func startObserving() {
        guard !isObserving else { return }
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(activeSourceDidChange(_:)),
            name: kTISNotifySelectedKeyboardInputSourceChanged as NSNotification.Name,
            object: nil
        )
        isObserving = true
    }

    private func stopObserving() {
        guard isObserving else { return }
        DistributedNotificationCenter.default().removeObserver(
            self,
            name: kTISNotifySelectedKeyboardInputSourceChanged as NSNotification.Name,
            object: nil
        )
        isObserving = false
    }

    @objc private func activeSourceDidChange(_ notification: Notification) {
        guard let id = activeSourceID() else { return }
        handler?(id)
    }

    private func findSource(id: InputSourceID) -> TISInputSource? {
        guard let list = TISCreateInputSourceList(nil, false)?.takeRetainedValue() as? [TISInputSource] else {
            return nil
        }
        return list.first { stringProperty($0, kTISPropertyInputSourceID) == id.rawValue }
    }

    private func stringProperty(_ source: TISInputSource, _ key: CFString) -> String? {
        guard let value = TISGetInputSourceProperty(source, key) else { return nil }
        let unmanaged = Unmanaged<CFTypeRef>.fromOpaque(value).takeUnretainedValue()
        return unmanaged as? String
    }

    private func boolProperty(_ source: TISInputSource, _ key: CFString) -> Bool? {
        guard let value = TISGetInputSourceProperty(source, key) else { return nil }
        let unmanaged = Unmanaged<CFTypeRef>.fromOpaque(value).takeUnretainedValue()
        return (unmanaged as? NSNumber)?.boolValue
    }
}
