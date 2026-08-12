import XCTest
@testable import WhatsThisInKannada

final class PracticeEngineTests: XCTestCase {
    func testFlashcardIndexWraps() {
        XCTAssertEqual(PracticeEngine.flashcardIndex(current: 0, count: 3, delta: -1), 2)
        XCTAssertEqual(PracticeEngine.flashcardIndex(current: 2, count: 3, delta: 1), 0)
        XCTAssertEqual(PracticeEngine.flashcardIndex(current: 1, count: 0, delta: 1), 0)
    }

    func testQuizRoundIncludesPromptAndUniqueChoices() {
        let words = [
            KannadaWord(id: "amma", english: "mother", kannada: "ಅಮ್ಮ", transliteration: "amma", imageName: "family_amma", category: .family, aliases: ["mom"]),
            KannadaWord(id: "appa", english: "father", kannada: "ಅಪ್ಪ", transliteration: "appa", imageName: "family_appa", category: .family, aliases: ["dad"]),
            KannadaWord(id: "bekku", english: "cat", kannada: "ಬೆಕ್ಕು", transliteration: "bekku", imageName: "animal_cat", category: .animals, aliases: ["cat"]),
            KannadaWord(id: "sebu", english: "apple", kannada: "ಸೇಬು", transliteration: "sebu", imageName: "fruit_apple", category: .fruits, aliases: ["apple"])
        ]
        let round = PracticeEngine.makeQuizRound(prompt: words[0], from: words, choiceCount: 4)

        XCTAssertEqual(round.prompt.id, "amma")
        XCTAssertEqual(round.choices.count, 4)
        XCTAssertEqual(Set(round.choices.map(\.id)).count, 4)
        XCTAssertTrue(round.choices.contains(where: { $0.id == "amma" }))
        XCTAssertTrue(PracticeEngine.isCorrect(choiceID: "amma", promptID: round.prompt.id))
        XCTAssertFalse(PracticeEngine.isCorrect(choiceID: "appa", promptID: round.prompt.id))
    }

    func testProgressClamps() {
        XCTAssertEqual(PracticeEngine.progress(completed: 0, total: 10), 0)
        XCTAssertEqual(PracticeEngine.progress(completed: 5, total: 10), 0.5)
        XCTAssertEqual(PracticeEngine.progress(completed: 12, total: 10), 1)
        XCTAssertEqual(PracticeEngine.progress(completed: 1, total: 0), 0)
    }
}
