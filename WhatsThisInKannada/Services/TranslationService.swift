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
        // V1 stays curated-only so unknown words never invent toddler-unsafe
        // translations. Home shows nearby catalog suggestions instead.
        throw TranslationServiceError.unavailable
    }
}
