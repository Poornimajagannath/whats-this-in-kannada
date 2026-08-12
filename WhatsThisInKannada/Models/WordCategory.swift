import Foundation
import SwiftUI

enum WordCategory: String, CaseIterable, Codable, Identifiable {
    case family
    case animals
    case fruits

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .family:
            return "Family"
        case .animals:
            return "Animals"
        case .fruits:
            return "Fruits"
        }
    }

    var kannadaName: String {
        switch self {
        case .family:
            return "ಕುಟುಂಬ"
        case .animals:
            return "ಪ್ರಾಣಿಗಳು"
        case .fruits:
            return "ಹಣ್ಣುಗಳು"
        }
    }

    var symbolName: String {
        switch self {
        case .family:
            return "heart.fill"
        case .animals:
            return "pawprint.fill"
        case .fruits:
            return "leaf.fill"
        }
    }

    var themeColor: Color {
        KannadaTheme.accent(for: self)
    }

    var softColor: Color {
        KannadaTheme.surfaceTint(for: self)
    }
}
