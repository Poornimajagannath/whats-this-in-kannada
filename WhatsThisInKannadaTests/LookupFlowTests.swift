import XCTest
@testable import WhatsThisInKannada

final class LookupFlowTests: XCTestCase {
    func testHomeStarterWordsResolve() throws {
        let catalog = WordCatalog(words: try loadSeed())
        let starters = ["amma", "appa", "ajji", "elephant", "mango", "dog"]

        for starter in starters {
            XCTAssertNotNil(catalog.lookupFromPhrase(starter), "Home starter '\(starter)' should resolve")
        }
    }

    func testUnknownWordStaysUnknownAndOffersSuggestions() throws {
        let catalog = WordCatalog(words: try loadSeed())
        XCTAssertNil(catalog.lookupFromPhrase("refrigerator"))
        XCTAssertFalse(catalog.suggestions(for: "refrigerator").isEmpty)
    }

    func testResultCardUnknownCannotSpeakOrFavorite() {
        let result = LookupResult.unknown(query: "fan")
        XCTAssertFalse(result.canSpeak)
        XCTAssertFalse(result.canFavorite)
        XCTAssertEqual(result.source, .unknown)
    }

    func testCuratedResultCanSpeakAndFavorite() throws {
        let catalog = WordCatalog(words: try loadSeed())
        let word = try XCTUnwrap(catalog.lookup("amma"))
        let result = LookupResult.curated(word, query: "mom")
        XCTAssertTrue(result.canSpeak)
        XCTAssertTrue(result.canFavorite)
        XCTAssertEqual(result.wordID, "amma")
        XCTAssertEqual(result.kannada, "ಅಮ್ಮ")
    }

    private func loadSeed() throws -> [KannadaWord] {
        var directory = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
        for _ in 0..<6 {
            let candidate = directory.appendingPathComponent("WhatsThisInKannada/Resources/word-seed.json")
            if FileManager.default.fileExists(atPath: candidate.path) {
                return try JSONDecoder().decode([KannadaWord].self, from: Data(contentsOf: candidate))
            }
            directory.deleteLastPathComponent()
        }
        throw NSError(domain: "LookupFlowTests", code: 1)
    }
}
