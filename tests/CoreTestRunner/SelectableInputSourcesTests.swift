import KeyboardSourceLocker

enum SelectableInputSourcesTests {
    static func run() {
        print("SelectableInputSources")
        keepsLayoutsAndSelectableIMEModes()
        dropsPaletteSources()
        dropsNonSelectableIMEParents()
    }

    private static func keepsLayoutsAndSelectableIMEModes() {
        let records = [
            InputSourceRecord(
                id: InputSourceID("com.apple.keylayout.ABC"),
                displayName: "ABC",
                category: .keyboard,
                isSelectCapable: true
            ),
            InputSourceRecord(
                id: InputSourceID("com.tencent.inputmethod.wetype.pinyin"),
                displayName: "微信输入法",
                category: .keyboard,
                isSelectCapable: true
            ),
        ]

        let result = SelectableInputSources.filter(records)
        Expect.equal(result.map(\.id.rawValue), [
            "com.apple.keylayout.ABC",
            "com.tencent.inputmethod.wetype.pinyin",
        ], "keeps layouts and selectable IME modes")
    }

    private static func dropsPaletteSources() {
        let records = [
            InputSourceRecord(
                id: InputSourceID("com.apple.keylayout.ABC"),
                displayName: "ABC",
                category: .keyboard,
                isSelectCapable: true
            ),
            InputSourceRecord(
                id: InputSourceID("com.apple.CharacterPaletteIM"),
                displayName: "Emoji & Symbols",
                category: .palette,
                isSelectCapable: true
            ),
            InputSourceRecord(
                id: InputSourceID("com.apple.PressAndHold"),
                displayName: "com.apple.PressAndHold",
                category: .palette,
                isSelectCapable: true
            ),
        ]

        let result = SelectableInputSources.filter(records)
        Expect.equal(result.map(\.displayName), ["ABC"], "drops palette sources")
    }

    private static func dropsNonSelectableIMEParents() {
        let records = [
            InputSourceRecord(
                id: InputSourceID("com.tencent.inputmethod.wetype.pinyin"),
                displayName: "微信输入法",
                category: .keyboard,
                isSelectCapable: true
            ),
            InputSourceRecord(
                id: InputSourceID("com.tencent.inputmethod.wetype"),
                displayName: "微信输入法",
                category: .keyboard,
                isSelectCapable: false
            ),
        ]

        let result = SelectableInputSources.filter(records)
        Expect.equal(
            result.map(\.id.rawValue),
            ["com.tencent.inputmethod.wetype.pinyin"],
            "drops non-selectable IME parent (duplicate WX)"
        )
    }
}
