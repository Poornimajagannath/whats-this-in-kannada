import Foundation

struct PhraseParser {
    private static let stopWords: Set<String> = [
        "a", "an", "and", "are", "can", "do", "does", "for", "here", "hey",
        "i", "in", "is", "it", "look", "me", "my", "now", "of", "on", "please",
        "see", "show", "that", "the", "there", "this", "to", "what", "where",
        "with", "you"
    ]

    static func normalize(_ input: String) -> String {
        input
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .lowercased()
            .replacingOccurrences(of: #"[^a-z0-9\s']"#, with: " ", options: .regularExpression)
            .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func tokens(from input: String) -> [String] {
        normalize(input)
            .split(separator: " ")
            .map(String.init)
            .filter { !$0.isEmpty }
    }

    static func extractKeyword(from phrase: String, catalog: WordCatalog) -> String? {
        let normalizedPhrase = normalize(phrase)
        guard !normalizedPhrase.isEmpty else { return nil }

        if let exact = catalog.lookup(normalizedPhrase) {
            return exact.english
        }

        let paddedPhrase = " \(normalizedPhrase) "
        let matches = catalog.words.compactMap { word -> (term: String, word: KannadaWord, length: Int)? in
            let terms = word.searchableTerms.map(normalize).filter { !$0.isEmpty }
            guard let longest = terms
                .filter({ paddedPhrase.contains(" \($0) ") || normalizedPhrase == $0 })
                .max(by: { $0.count < $1.count })
            else {
                return nil
            }

            return (longest, word, longest.count)
        }

        if let best = matches.sorted(by: { $0.length > $1.length }).first {
            return best.term
        }

        let meaningful = tokens(from: phrase).filter { !stopWords.contains($0) }
        return meaningful.last ?? normalizedPhrase
    }
}
