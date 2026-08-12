import Foundation

@MainActor
final class FavoritesStore: ObservableObject {
    @Published private(set) var savedWords: [SavedWord] = []

    private let defaults: UserDefaults
    private let key = "saved_words_v1"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.savedWords = Self.load(from: defaults, key: key)
    }

    func contains(_ wordID: String) -> Bool {
        savedWords.contains { $0.wordID == wordID }
    }

    func toggle(_ word: KannadaWord) {
        if contains(word.id) {
            remove(wordID: word.id)
        } else {
            savedWords.insert(SavedWord(word: word), at: 0)
            save()
        }
    }

    func remove(_ savedWord: SavedWord) {
        remove(wordID: savedWord.wordID)
    }

    func remove(wordID: String) {
        savedWords.removeAll { $0.wordID == wordID }
        save()
    }

    func markPracticed(wordID: String, learned: Bool? = nil) {
        guard let index = savedWords.firstIndex(where: { $0.wordID == wordID }) else { return }
        savedWords[index].timesPracticed += 1
        if let learned {
            savedWords[index].learned = learned
        }
        save()
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(savedWords) else { return }
        defaults.set(data, forKey: key)
    }

    private static func load(from defaults: UserDefaults, key: String) -> [SavedWord] {
        guard
            let data = defaults.data(forKey: key),
            let decoded = try? JSONDecoder().decode([SavedWord].self, from: data)
        else {
            return []
        }

        return decoded.sorted { $0.createdAt > $1.createdAt }
    }
}
