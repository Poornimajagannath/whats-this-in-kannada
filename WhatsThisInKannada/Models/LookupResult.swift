import Foundation

struct LookupResult: Identifiable, Hashable {
    enum Source: String, Hashable {
        case curated
        case translated
        case unknown
    }

    let id = UUID()
    let source: Source
    let query: String
    let wordID: String?
    let english: String
    let kannada: String
    let transliteration: String
    let imageName: String
    let category: WordCategory?
    let message: String?

    var canSpeak: Bool {
        !kannada.isEmpty && source != .unknown
    }

    var canFavorite: Bool {
        wordID != nil && source != .unknown
    }

    static func curated(_ word: KannadaWord, query: String) -> LookupResult {
        LookupResult(
            source: .curated,
            query: query,
            wordID: word.id,
            english: word.english,
            kannada: word.kannada,
            transliteration: word.transliteration,
            imageName: word.imageName,
            category: word.category,
            message: nil
        )
    }

    static func unknown(query: String) -> LookupResult {
        LookupResult(
            source: .unknown,
            query: query,
            wordID: nil,
            english: query,
            kannada: "Not in library yet",
            transliteration: "",
            imageName: "unknown_word",
            category: nil,
            message: "Try a family word, animal, or fruit from the Library."
        )
    }
}
