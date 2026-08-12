import XCTest
@testable import WhatsThisInKannada

final class PhraseParserTests: XCTestCase {
    private let catalog = WordCatalog(words: [
        KannadaWord(id: "aane", english: "elephant", kannada: "ಆನೆ", transliteration: "aane", imageName: "animal_elephant", category: .animals, aliases: ["elephant"]),
        KannadaWord(id: "appa", english: "father", kannada: "ಅಪ್ಪ", transliteration: "appa", imageName: "family_appa", category: .family, aliases: ["dad", "daddy", "appa"]),
        KannadaWord(id: "maavinahannu", english: "mango", kannada: "ಮಾವಿನಹಣ್ಣು", transliteration: "maavinahannu", imageName: "fruit_mango", category: .fruits, aliases: ["mango"])
    ])

    func testExtractsKnownWordFromPhrase() {
        XCTAssertEqual(PhraseParser.extractKeyword(from: "this is an elephant", catalog: catalog), "elephant")
        XCTAssertEqual(PhraseParser.extractKeyword(from: "where is appa", catalog: catalog), "appa")
        XCTAssertEqual(PhraseParser.extractKeyword(from: "show me mango please", catalog: catalog), "mango")
    }

    func testFallsBackToMeaningfulToken() {
        XCTAssertEqual(PhraseParser.extractKeyword(from: "this is a rainbow", catalog: catalog), "rainbow")
    }

    func testKeepsKannadaScript() {
        XCTAssertEqual(PhraseParser.normalize("ಅಮ್ಮ"), "ಅಮ್ಮ")
        XCTAssertEqual(PhraseParser.extractKeyword(from: "ಆನೆ", catalog: catalog), "elephant")
        XCTAssertEqual(PhraseParser.extractKeyword(from: "this is ಅಪ್ಪ", catalog: catalog), "ಅಪ್ಪ")
    }

    func testEmptyAndPunctuation() {
        XCTAssertNil(PhraseParser.extractKeyword(from: "   ", catalog: catalog))
        XCTAssertEqual(PhraseParser.extractKeyword(from: "elephant!!!", catalog: catalog), "elephant")
    }
}
