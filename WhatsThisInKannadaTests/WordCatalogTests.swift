import XCTest
@testable import WhatsThisInKannada

final class WordCatalogTests: XCTestCase {
    private let catalog = WordCatalog(words: [
        KannadaWord(id: "amma", english: "mother", kannada: "ಅಮ್ಮ", transliteration: "amma", imageName: "family_amma", category: .family, aliases: ["mom", "mommy", "amma"]),
        KannadaWord(id: "bekku", english: "cat", kannada: "ಬೆಕ್ಕು", transliteration: "bekku", imageName: "animal_cat", category: .animals, aliases: ["cat", "kitten"]),
        KannadaWord(id: "sebu", english: "apple", kannada: "ಸೇಬು", transliteration: "sebu", imageName: "fruit_apple", category: .fruits, aliases: ["apple"])
    ])

    func testLookupMatchesAliases() {
        XCTAssertEqual(catalog.lookup("mom")?.id, "amma")
        XCTAssertEqual(catalog.lookup("kitten")?.id, "bekku")
    }

    func testSearchFiltersByCategory() {
        XCTAssertEqual(catalog.search("a", category: .animals).map(\.id), ["bekku"])
        XCTAssertEqual(catalog.search("apple", category: .fruits).first?.id, "sebu")
    }

    func testSearchMatchesWholeTokensInsideAPhraseButNotShorterWords() throws {
        let catalog = WordCatalog(words: try Self.loadProductionSeedWords())

        XCTAssertEqual(catalog.search("elephant").map(\.id), ["aane"])
        XCTAssertEqual(catalog.search("baby elephant").map(\.id), ["magu", "aane"])
        XCTAssertEqual(catalog.search("ajji").map(\.id), ["ajji"])
        XCTAssertEqual(catalog.search("spaceship").map(\.id), [])
    }

    func testKannadaWordDecodesLegacySeedShape() throws {
        let data = """
        [
          {
            "id": "amma",
            "english": "mother",
            "kannada": "ಅಮ್ಮ",
            "transliteration": "amma",
            "imageName": "family_amma",
            "category": "family",
            "aliases": ["mom", "mommy", "amma"]
          }
        ]
        """.data(using: .utf8)!

        let words = try JSONDecoder().decode([KannadaWord].self, from: data)

        XCTAssertEqual(words.first?.id, "amma")
        XCTAssertEqual(words.first?.familyVariantGroupID, "parent")
        XCTAssertEqual(words.first?.objectPackIDs ?? [], [KannadaObjectPackID.firstUseful, .family, .familyHome])
    }

    func testFamilyVariantMetadataIsDerivedFromExistingWordData() {
        let amma = KannadaWord(id: "amma", english: "mother", kannada: "ಅಮ್ಮ", transliteration: "amma", imageName: "family_amma", category: .family, aliases: ["mom"])
        let appa = KannadaWord(id: "appa", english: "father", kannada: "ಅಪ್ಪ", transliteration: "appa", imageName: "family_appa", category: .family, aliases: ["dad"])
        let tamma = KannadaWord(id: "tamma", english: "younger brother", kannada: "ತಮ್ಮ", transliteration: "tamma", imageName: "family_boy", category: .family, aliases: ["little brother"])
        let gelathi = KannadaWord(id: "gelathi", english: "friend", kannada: "ಗೆಳತಿ", transliteration: "gelathi", imageName: "family_friend_girl", category: .family, aliases: ["friend", "female friend"])
        let aunt = KannadaWord(id: "doddaatte", english: "elder aunt", kannada: "ದೊಡ್ಡತ್ತೆ", transliteration: "doddaatte", imageName: "family_woman", category: .family, aliases: ["aunt"])
        let cat = KannadaWord(id: "bekku", english: "cat", kannada: "ಬೆಕ್ಕು", transliteration: "bekku", imageName: "animal_cat", category: .animals, aliases: ["cat"])

        XCTAssertEqual(amma.familyVariantGroupID, "parent")
        XCTAssertEqual(amma.familyVariantGender, "feminine")
        XCTAssertEqual(amma.familyVariantCounterpartID, "appa")
        XCTAssertEqual(appa.familyVariantGroupID, "parent")
        XCTAssertEqual(appa.familyVariantGender, "masculine")
        XCTAssertEqual(appa.familyVariantCounterpartID, "amma")
        XCTAssertEqual(tamma.familyVariantGroupID, "sibling")
        XCTAssertEqual(tamma.familyVariantGender, "masculine")
        XCTAssertEqual(tamma.familyVariantAgeScope, "younger")
        XCTAssertEqual(tamma.familyVariantCounterpartID, "thangi")
        XCTAssertEqual(gelathi.familyVariantGroupID, "friend")
        XCTAssertEqual(gelathi.familyVariantGender, "feminine")
        XCTAssertEqual(aunt.familyVariantGroupID, "aunt")
        XCTAssertEqual(aunt.familyVariantAgeScope, "elder")
        XCTAssertNil(cat.familyVariant)
    }

    func testObjectPackHelpersUseCatalogSourceOfTruthOrder() {
        let packCatalog = WordCatalog(words: [
            KannadaWord(id: "bekku", english: "cat", kannada: "ಬೆಕ್ಕು", transliteration: "bekku", imageName: "animal_cat", category: .animals, aliases: ["cat"]),
            KannadaWord(id: "appa", english: "father", kannada: "ಅಪ್ಪ", transliteration: "appa", imageName: "family_appa", category: .family, aliases: ["dad"]),
            KannadaWord(id: "amma", english: "mother", kannada: "ಅಮ್ಮ", transliteration: "amma", imageName: "family_amma", category: .family, aliases: ["mom"]),
            KannadaWord(id: "sebu", english: "apple", kannada: "ಸೇಬು", transliteration: "sebu", imageName: "fruit_apple", category: .fruits, aliases: ["apple"]),
            KannadaWord(id: "naayi", english: "dog", kannada: "ನಾಯಿ", transliteration: "naayi", imageName: "animal_dog", category: .animals, aliases: ["dog"]),
            KannadaWord(id: "magu", english: "baby", kannada: "ಮಗು", transliteration: "magu", imageName: "family_magu", category: .family, aliases: ["baby"])
        ])

        XCTAssertEqual(packCatalog.firstUsefulWords().map(\.id), ["amma", "appa", "magu", "bekku", "naayi", "sebu"])
        XCTAssertEqual(packCatalog.words(inObjectPack: .familyHome).map(\.id), ["amma", "appa", "magu"])
        XCTAssertEqual(Array(packCatalog.objectPack(.animals)?.wordIDs.prefix(3) ?? []), ["naayi", "bekku", "hasu"])
        XCTAssertEqual(packCatalog.objectPack(.animals)?.words.map(\.id) ?? [], ["naayi", "bekku"])
    }

    func testProductionSeedResolvesEveryObjectPackID() throws {
        let catalog = WordCatalog(words: try Self.loadProductionSeedWords())

        for pack in catalog.objectPacks {
            let resolvedIDs = pack.words.map(\.id)
            let missingIDs = pack.wordIDs.filter { !resolvedIDs.contains($0) }
            XCTAssertTrue(missingIDs.isEmpty, "\(pack.id.rawValue) has missing IDs: \(missingIDs)")
            XCTAssertEqual(Set(pack.wordIDs).count, pack.wordIDs.count, "\(pack.id.rawValue) has duplicate IDs")
        }

        XCTAssertEqual(catalog.firstUsefulWords().map(\.id), KannadaWord.firstUsefulWordIDs)
        XCTAssertEqual(catalog.words(inObjectPack: .familyHome).map(\.id), KannadaWord.familyHomePackWordIDs)
    }

    func testSafeCuratedLookupReturnsOnlyUnambiguousCuratedMatches() {
        let ambiguousCatalog = WordCatalog(words: [
            KannadaWord(id: "maava", english: "uncle", kannada: "ಮಾವ", transliteration: "maava", imageName: "family_maava", category: .family, aliases: ["uncle", "maternal uncle"]),
            KannadaWord(id: "chikkappa", english: "father's younger brother", kannada: "ಚಿಕ್ಕಪ್ಪ", transliteration: "chikkappa", imageName: "family_chikkappa", category: .family, aliases: ["uncle"]),
            KannadaWord(id: "geleya", english: "friend", kannada: "ಗೆಳೆಯ", transliteration: "geleya", imageName: "family_friend_boy", category: .family, aliases: ["friend", "male friend"]),
            KannadaWord(id: "gelathi", english: "friend", kannada: "ಗೆಳತಿ", transliteration: "gelathi", imageName: "family_friend_girl", category: .family, aliases: ["friend", "female friend"])
        ])

        XCTAssertEqual(ambiguousCatalog.safeCuratedLookup("maava")?.id, "maava")
        XCTAssertEqual(ambiguousCatalog.safeCuratedLookup("male friend")?.id, "geleya")
        XCTAssertEqual(ambiguousCatalog.safeCuratedLookup("ಗೆಳತಿ")?.id, "gelathi")
        XCTAssertNil(ambiguousCatalog.safeCuratedLookup("uncle"))
        XCTAssertNil(ambiguousCatalog.safeCuratedLookup("friend"))
    }

    func testLookupFromPhrasePreservesDisambiguatingFamilyTerms() {
        let ambiguousCatalog = WordCatalog(words: [
            KannadaWord(id: "geleya", english: "friend", kannada: "ಗೆಳೆಯ", transliteration: "geleya", imageName: "family_friend_boy", category: .family, aliases: ["friend", "male friend"]),
            KannadaWord(id: "gelathi", english: "friend", kannada: "ಗೆಳತಿ", transliteration: "gelathi", imageName: "family_friend_girl", category: .family, aliases: ["friend", "female friend"])
        ])

        XCTAssertEqual(ambiguousCatalog.lookupFromPhrase("show me male friend")?.id, "geleya")
        XCTAssertEqual(ambiguousCatalog.lookupFromPhrase("show me female friend")?.id, "gelathi")
        XCTAssertNil(ambiguousCatalog.lookupFromPhrase("show me friend"))
    }

    func testLookupFromPhraseAcceptsKannadaAndSuggestions() throws {
        let catalog = WordCatalog(words: try Self.loadProductionSeedWords())

        XCTAssertEqual(catalog.lookupFromPhrase("ಅಮ್ಮ")?.id, "amma")
        XCTAssertEqual(catalog.lookupFromPhrase("this is an elephant")?.id, "aane")
        XCTAssertNil(catalog.lookupFromPhrase("fan"))

        let mangoSuggestions = catalog.suggestions(for: "mang", limit: 3)
        XCTAssertEqual(mangoSuggestions.first?.id, "maavinahannu")

        let unknownSuggestions = catalog.suggestions(for: "xyzzy", limit: 3)
        XCTAssertEqual(unknownSuggestions.map(\.id), Array(KannadaWord.firstUsefulWordIDs.prefix(3)))
    }

    private static func loadProductionSeedWords(filePath: String = #filePath) throws -> [KannadaWord] {
        var directory = URL(fileURLWithPath: filePath).deletingLastPathComponent()

        for _ in 0..<6 {
            let candidate = directory.appendingPathComponent("WhatsThisInKannada/Resources/word-seed.json")
            if FileManager.default.fileExists(atPath: candidate.path) {
                let data = try Data(contentsOf: candidate)
                return try JSONDecoder().decode([KannadaWord].self, from: data)
            }
            directory.deleteLastPathComponent()
        }

        throw NSError(
            domain: "WordCatalogTests",
            code: 1,
            userInfo: [NSLocalizedDescriptionKey: "Could not locate WhatsThisInKannada/Resources/word-seed.json"]
        )
    }
}
