import Foundation

struct KannadaObjectPack: Identifiable, Hashable {
    let id: KannadaObjectPackID
    let title: String
    let wordIDs: [String]
    let words: [KannadaWord]

    var isEmpty: Bool {
        words.isEmpty
    }
}

struct WordCatalog {
    static let shared = WordCatalog()

    let words: [KannadaWord]

    init(bundle: Bundle = .main) {
        self.words = Self.loadWords(from: bundle)
    }

    init(words: [KannadaWord]) {
        self.words = Self.curatedSort(words)
    }

    func words(in category: WordCategory?) -> [KannadaWord] {
        guard let category else { return words }
        return words.filter { $0.category == category }
    }

    var objectPacks: [KannadaObjectPack] {
        Self.objectPackDefinitions.map { definition in
            KannadaObjectPack(
                id: definition.id,
                title: definition.id.displayName,
                wordIDs: definition.wordIDs,
                words: words(matchingIDs: definition.wordIDs)
            )
        }
    }

    func objectPack(_ packID: KannadaObjectPackID) -> KannadaObjectPack? {
        objectPacks.first { $0.id == packID }
    }

    func words(inObjectPack packID: KannadaObjectPackID) -> [KannadaWord] {
        objectPack(packID)?.words ?? []
    }

    func firstUsefulWords(limit: Int = KannadaWord.firstUsefulWordIDs.count) -> [KannadaWord] {
        Array(words(inObjectPack: .firstUseful).prefix(max(0, limit)))
    }

    func search(_ query: String, category: WordCategory? = nil) -> [KannadaWord] {
        let candidates = words(in: category)
        let normalizedQuery = PhraseParser.normalize(query)
        guard !normalizedQuery.isEmpty else { return candidates }

        let queryTokens = Set(PhraseParser.tokens(from: normalizedQuery))

        return candidates.filter { word in
            word.searchableTerms
                .map(PhraseParser.normalize)
                .contains { term in
                    // "ele" matches elephant. "baby elephant" matches both words.
                    // A whole token only, so "elephant" does not also return "ant".
                    term.contains(normalizedQuery) || queryTokens.contains(term)
                }
        }
    }

    func lookup(_ query: String) -> KannadaWord? {
        let normalizedQuery = PhraseParser.normalize(query)
        guard !normalizedQuery.isEmpty else { return nil }

        return words.first { word in
            word.searchableTerms
                .map(PhraseParser.normalize)
                .contains(normalizedQuery)
        }
    }

    func safeCuratedLookup(_ query: String) -> KannadaWord? {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedQuery = PhraseParser.normalize(query)
        guard !trimmedQuery.isEmpty || !normalizedQuery.isEmpty else { return nil }

        let exactKannadaMatches = words.filter { $0.kannada == trimmedQuery }
        if exactKannadaMatches.count == 1 {
            return exactKannadaMatches[0]
        }

        guard !normalizedQuery.isEmpty else { return nil }

        let exactIdentityMatches = words.filter { word in
            PhraseParser.normalize(word.id) == normalizedQuery
                || PhraseParser.normalize(word.transliteration) == normalizedQuery
        }
        if exactIdentityMatches.count == 1 {
            return exactIdentityMatches[0]
        }

        let exactTermMatches = words.filter { word in
            word.searchableTerms
                .map(PhraseParser.normalize)
                .contains(normalizedQuery)
        }

        guard exactTermMatches.count == 1 else { return nil }
        return exactTermMatches[0]
    }

    func lookupFromPhrase(_ phrase: String) -> KannadaWord? {
        let trimmed = phrase.trimmingCharacters(in: .whitespacesAndNewlines)
        if let direct = safeCuratedLookup(trimmed) {
            return direct
        }

        guard let keyword = PhraseParser.extractKeyword(from: phrase, catalog: self) else {
            return nil
        }

        return safeCuratedLookup(keyword)
    }

    func suggestions(for query: String, limit: Int = 3) -> [KannadaWord] {
        let normalizedQuery = PhraseParser.normalize(query)
        guard !normalizedQuery.isEmpty else {
            return Array(firstUsefulWords().prefix(max(0, limit)))
        }

        let ranked = words.compactMap { word -> (KannadaWord, Int)? in
            let terms = word.searchableTerms
                .map(PhraseParser.normalize)
                .filter { !$0.isEmpty }

            if terms.contains(where: { $0 == normalizedQuery }) {
                return (word, 0)
            }
            if terms.contains(where: { $0.hasPrefix(normalizedQuery) || normalizedQuery.hasPrefix($0) }) {
                return (word, 1)
            }
            if terms.contains(where: { $0.contains(normalizedQuery) || normalizedQuery.contains($0) }) {
                return (word, 2)
            }
            return nil
        }
        .sorted { lhs, rhs in
            if lhs.1 != rhs.1 {
                return lhs.1 < rhs.1
            }
            return lhs.0.id < rhs.0.id
        }

        var seen = Set<String>()
        let matches = ranked.compactMap { pair -> KannadaWord? in
            seen.insert(pair.0.id).inserted ? pair.0 : nil
        }

        if matches.isEmpty {
            return Array(firstUsefulWords().prefix(max(0, limit)))
        }

        return Array(matches.prefix(max(0, limit)))
    }

    private static func loadWords(from bundle: Bundle) -> [KannadaWord] {
        guard
            let url = bundle.url(forResource: "word-seed", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let decoded = try? JSONDecoder().decode([KannadaWord].self, from: data)
        else {
            return fallbackWords
        }

        return curatedSort(decoded)
    }

    private static func curatedSort(_ words: [KannadaWord]) -> [KannadaWord] {
        words.enumerated()
            .sorted { lhs, rhs in
                let lhsCategory = categoryRank(lhs.element.category)
                let rhsCategory = categoryRank(rhs.element.category)
                if lhsCategory != rhsCategory {
                    return lhsCategory < rhsCategory
                }

                let lhsOrder = orderIndex(lhs.element)
                let rhsOrder = orderIndex(rhs.element)
                if lhsOrder != rhsOrder {
                    return lhsOrder < rhsOrder
                }

                return lhs.offset < rhs.offset
            }
            .map(\.element)
    }

    private static func categoryRank(_ category: WordCategory) -> Int {
        switch category {
        case .family:
            return 0
        case .animals:
            return 1
        case .fruits:
            return 2
        }
    }

    private static func orderIndex(_ word: KannadaWord) -> Int {
        categoryOrder[word.category]?.firstIndex(of: word.id) ?? Int.max
    }

    private func words(matchingIDs ids: [String]) -> [KannadaWord] {
        ids.compactMap { id in
            words.first { $0.id == id }
        }
    }

    private struct ObjectPackDefinition {
        let id: KannadaObjectPackID
        let wordIDs: [String]
    }

    private static let objectPackDefinitions = [
        ObjectPackDefinition(id: .firstUseful, wordIDs: KannadaWord.firstUsefulWordIDs),
        ObjectPackDefinition(id: .familyHome, wordIDs: KannadaWord.familyHomePackWordIDs),
        ObjectPackDefinition(id: .family, wordIDs: categoryOrder[.family] ?? []),
        ObjectPackDefinition(id: .animals, wordIDs: categoryOrder[.animals] ?? []),
        ObjectPackDefinition(id: .fruits, wordIDs: categoryOrder[.fruits] ?? [])
    ]

    private static let categoryOrder: [WordCategory: [String]] = [
        .family: [
            "amma", "appa", "magu",
            "ajji", "taatha", "anna",
            "akka", "tamma", "thangi",
            "maga", "magalu", "maava",
            "atte", "chikkappa", "doddappa",
            "chikkamma", "doddamma", "geleya", "gelathi"
        ],
        .animals: [
            "naayi", "bekku", "hasu", "aane",
            "kudure", "huli", "simha", "koti",
            "mola", "hakki", "meenu", "kappe",
            "aame", "chitte", "emme", "meke",
            "kuri", "karadi", "jinke", "koli",
            "baatukoli", "haavu", "iruve"
        ],
        .fruits: [
            "sebu", "baalehannu", "maavinahannu", "kittale",
            "draakshi", "kallangadi", "ananas", "straaberi",
            "thenginakaayi", "nimbehannu", "parangihannu", "seebehannu",
            "daalimbe", "halasinahannu", "kharjoora", "karbooja", "sapota"
        ]
    ]

    private static let fallbackWords: [KannadaWord] = [
        KannadaWord(id: "amma", english: "mother", kannada: "ಅಮ್ಮ", transliteration: "amma", imageName: "family_amma", category: .family, aliases: ["mom", "mommy", "amma"]),
        KannadaWord(id: "appa", english: "father", kannada: "ಅಪ್ಪ", transliteration: "appa", imageName: "family_appa", category: .family, aliases: ["dad", "daddy", "appa"]),
        KannadaWord(id: "ajji", english: "grandmother", kannada: "ಅಜ್ಜಿ", transliteration: "ajji", imageName: "family_ajji", category: .family, aliases: ["grandma", "ajji"]),
        KannadaWord(id: "taatha", english: "grandfather", kannada: "ತಾತ", transliteration: "taatha", imageName: "family_taatha", category: .family, aliases: ["grandpa", "taatha", "tatha"]),
        KannadaWord(id: "aane", english: "elephant", kannada: "ಆನೆ", transliteration: "aane", imageName: "animal_elephant", category: .animals, aliases: ["elephant"]),
        KannadaWord(id: "maavinahannu", english: "mango", kannada: "ಮಾವಿನಹಣ್ಣು", transliteration: "maavinahannu", imageName: "fruit_mango", category: .fruits, aliases: ["mango"])
    ]
}
