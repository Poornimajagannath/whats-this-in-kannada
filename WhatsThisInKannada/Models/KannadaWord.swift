import Foundation

enum KannadaObjectPackID: String, CaseIterable, Codable, Hashable, Identifiable {
    case firstUseful = "first-useful"
    case familyHome = "family-home"
    case family
    case animals
    case fruits

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .firstUseful:
            return "First useful words"
        case .familyHome:
            return "Family home words"
        case .family:
            return "Family"
        case .animals:
            return "Animals"
        case .fruits:
            return "Fruits"
        }
    }
}

struct FamilyVariantMetadata: Hashable {
    let groupID: String
    let label: String
    let gender: String?
    let ageScope: String?
    let counterpartID: String?
}

struct KannadaWord: Identifiable, Codable, Hashable {
    let id: String
    let english: String
    let kannada: String
    let transliteration: String
    let imageName: String
    let category: WordCategory
    let aliases: [String]

    var searchableTerms: [String] {
        ([id, english, kannada, transliteration] + aliases)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    var displayEnglish: String {
        switch id {
        case "geleya", "gelathi":
            "Friend"
        default:
            english.capitalized
        }
    }

    var categoryObjectPackID: KannadaObjectPackID {
        switch category {
        case .family:
            return .family
        case .animals:
            return .animals
        case .fruits:
            return .fruits
        }
    }

    var objectPackIDs: [KannadaObjectPackID] {
        var packIDs = [categoryObjectPackID]
        if isFirstUsefulWord {
            packIDs.insert(.firstUseful, at: 0)
        }
        if isFamilyHomePackWord {
            packIDs.append(.familyHome)
        }
        return packIDs
    }

    var isFamilyWord: Bool {
        category == .family
    }

    var isFamilyHomePackWord: Bool {
        Self.familyHomePackWordIDs.contains(id)
    }

    var familyHomePackRank: Int? {
        Self.familyHomePackWordIDs.firstIndex(of: id)
    }

    var isFirstUsefulWord: Bool {
        Self.firstUsefulWordIDs.contains(id)
    }

    var firstUsefulRank: Int? {
        Self.firstUsefulWordIDs.firstIndex(of: id)
    }

    var familyVariant: FamilyVariantMetadata? {
        guard isFamilyWord else { return nil }

        if let known = Self.knownFamilyVariants[id] {
            return known
        }

        let normalizedEnglish = english.lowercased()
        let groupID: String
        if normalizedEnglish.contains("brother") || normalizedEnglish.contains("sister") {
            groupID = "sibling"
        } else if normalizedEnglish.contains("aunt") {
            groupID = "aunt"
        } else if normalizedEnglish.contains("uncle") {
            groupID = "uncle"
        } else if normalizedEnglish.contains("friend") {
            groupID = "friend"
        } else {
            groupID = id
        }

        return FamilyVariantMetadata(
            groupID: groupID,
            label: displayEnglish,
            gender: derivedFamilyGender,
            ageScope: derivedFamilyAgeScope,
            counterpartID: nil
        )
    }

    var familyVariantGroupID: String? {
        familyVariant?.groupID
    }

    var familyVariantLabel: String? {
        familyVariant?.label
    }

    var familyVariantGender: String? {
        familyVariant?.gender
    }

    var familyVariantAgeScope: String? {
        familyVariant?.ageScope
    }

    var familyVariantCounterpartID: String? {
        familyVariant?.counterpartID
    }

    private var derivedFamilyGender: String? {
        let normalizedEnglish = english.lowercased()
        let normalizedImageName = imageName.lowercased()
        let terms = searchableTerms.map { $0.lowercased() }

        if normalizedEnglish.contains("mother")
            || normalizedEnglish.contains("sister")
            || normalizedEnglish.contains("daughter")
            || normalizedEnglish.contains("aunt")
            || normalizedEnglish.contains("girl")
            || normalizedImageName.contains("girl")
            || normalizedImageName.contains("woman")
            || terms.contains("mom")
            || terms.contains("mommy") {
            return "feminine"
        }

        if normalizedEnglish.contains("father")
            || normalizedEnglish.contains("brother")
            || normalizedEnglish.contains("son")
            || normalizedEnglish.contains("uncle")
            || normalizedEnglish.contains("boy")
            || normalizedImageName.contains("boy")
            || normalizedImageName.contains("man")
            || terms.contains("dad")
            || terms.contains("daddy") {
            return "masculine"
        }

        return nil
    }

    private var derivedFamilyAgeScope: String? {
        let normalizedEnglish = english.lowercased()
        if normalizedEnglish.contains("elder")
            || normalizedEnglish.contains("older")
            || normalizedEnglish.contains("big")
            || id.hasPrefix("dodda") {
            return "elder"
        }

        if normalizedEnglish.contains("younger")
            || normalizedEnglish.contains("little")
            || id.hasPrefix("chikka") {
            return "younger"
        }

        return nil
    }

    static let firstUsefulWordIDs = [
        "amma", "appa", "magu", "bekku",
        "naayi", "baalehannu", "sebu", "aane"
    ]

    static let familyHomePackWordIDs = [
        "amma", "appa", "magu", "ajji", "taatha",
        "anna", "akka", "tamma", "thangi",
        "maga", "magalu", "geleya", "gelathi"
    ]

    private static let knownFamilyVariants: [String: FamilyVariantMetadata] = [
        "amma": FamilyVariantMetadata(groupID: "parent", label: "Mother", gender: "feminine", ageScope: nil, counterpartID: "appa"),
        "appa": FamilyVariantMetadata(groupID: "parent", label: "Father", gender: "masculine", ageScope: nil, counterpartID: "amma"),
        "ajji": FamilyVariantMetadata(groupID: "grandparent", label: "Grandmother", gender: "feminine", ageScope: "elder", counterpartID: "taatha"),
        "taatha": FamilyVariantMetadata(groupID: "grandparent", label: "Grandfather", gender: "masculine", ageScope: "elder", counterpartID: "ajji"),
        "anna": FamilyVariantMetadata(groupID: "sibling", label: "Elder brother", gender: "masculine", ageScope: "elder", counterpartID: "akka"),
        "akka": FamilyVariantMetadata(groupID: "sibling", label: "Elder sister", gender: "feminine", ageScope: "elder", counterpartID: "anna"),
        "tamma": FamilyVariantMetadata(groupID: "sibling", label: "Younger brother", gender: "masculine", ageScope: "younger", counterpartID: "thangi"),
        "thangi": FamilyVariantMetadata(groupID: "sibling", label: "Younger sister", gender: "feminine", ageScope: "younger", counterpartID: "tamma"),
        "maga": FamilyVariantMetadata(groupID: "child", label: "Son", gender: "masculine", ageScope: nil, counterpartID: "magalu"),
        "magalu": FamilyVariantMetadata(groupID: "child", label: "Daughter", gender: "feminine", ageScope: nil, counterpartID: "maga"),
        "geleya": FamilyVariantMetadata(groupID: "friend", label: "Friend", gender: "masculine", ageScope: nil, counterpartID: "gelathi"),
        "gelathi": FamilyVariantMetadata(groupID: "friend", label: "Friend", gender: "feminine", ageScope: nil, counterpartID: "geleya")
    ]
}
