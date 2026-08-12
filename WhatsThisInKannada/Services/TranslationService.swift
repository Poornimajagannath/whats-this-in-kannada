import Foundation

enum TranslationServiceError: LocalizedError {
    case unavailable

    var errorDescription: String? {
        switch self {
        case .unavailable:
            return "Translation is not available yet. The curated library still works offline."
        }
    }
}

struct TranslationService {
    func translateEnglishToKannada(_ text: String) async throws -> LookupResult {
        // The curated toddler catalog is the MVP path. Apple Translation can be
        // wired here once the app's deployment target and translation session
        // UX are finalized in Xcode.
        throw TranslationServiceError.unavailable
    }
}
