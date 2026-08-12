import Foundation

struct SavedWord: Identifiable, Codable, Hashable {
    var id: String { wordID }

    let wordID: String
    var english: String
    var kannada: String
    var transliteration: String
    var imageName: String
    var categoryRawValue: String
    var createdAt: Date
    var timesPracticed: Int
    var learned: Bool

    init(
        wordID: String,
        english: String,
        kannada: String,
        transliteration: String,
        imageName: String,
        categoryRawValue: String,
        createdAt: Date = .now,
        timesPracticed: Int = 0,
        learned: Bool = false
    ) {
        self.wordID = wordID
        self.english = english
        self.kannada = kannada
        self.transliteration = transliteration
        self.imageName = imageName
        self.categoryRawValue = categoryRawValue
        self.createdAt = createdAt
        self.timesPracticed = timesPracticed
        self.learned = learned
    }

    init(word: KannadaWord) {
        self.init(
            wordID: word.id,
            english: word.english,
            kannada: word.kannada,
            transliteration: word.transliteration,
            imageName: word.imageName,
            categoryRawValue: word.category.rawValue
        )
    }

    var category: WordCategory {
        WordCategory(rawValue: categoryRawValue) ?? .family
    }
}
