import XCTest
@testable import WhatsThisInKannada

@MainActor
final class FavoritesStoreTests: XCTestCase {
    func testTogglePersistsAndRemoves() {
        let defaults = UserDefaults(suiteName: "FavoritesStoreTests.\(UUID().uuidString)")!
        let store = FavoritesStore(defaults: defaults)
        let word = KannadaWord(
            id: "amma",
            english: "mother",
            kannada: "ಅಮ್ಮ",
            transliteration: "amma",
            imageName: "family_amma",
            category: .family,
            aliases: ["mom"]
        )

        XCTAssertFalse(store.contains("amma"))
        store.toggle(word)
        XCTAssertTrue(store.contains("amma"))
        XCTAssertEqual(store.savedWords.first?.kannada, "ಅಮ್ಮ")

        let reloaded = FavoritesStore(defaults: defaults)
        XCTAssertTrue(reloaded.contains("amma"))

        reloaded.toggle(word)
        XCTAssertFalse(reloaded.contains("amma"))
        XCTAssertTrue(reloaded.savedWords.isEmpty)
    }

    func testMarkPracticedUpdatesCount() {
        let defaults = UserDefaults(suiteName: "FavoritesStoreTests.\(UUID().uuidString)")!
        let store = FavoritesStore(defaults: defaults)
        let word = KannadaWord(
            id: "appa",
            english: "father",
            kannada: "ಅಪ್ಪ",
            transliteration: "appa",
            imageName: "family_appa",
            category: .family,
            aliases: ["dad"]
        )

        store.toggle(word)
        store.markPracticed(wordID: "appa", learned: true)
        XCTAssertEqual(store.savedWords.first?.timesPracticed, 1)
        XCTAssertEqual(store.savedWords.first?.learned, true)
    }
}
