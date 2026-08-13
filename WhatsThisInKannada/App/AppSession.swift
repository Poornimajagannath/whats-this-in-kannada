import Foundation

enum AppTab: Hashable {
    case home
    case learn
    case play
    case parent
}

@MainActor
final class AppSession: ObservableObject {
    @Published var selectedTab: AppTab = .home
    @Published var libraryCategory: WordCategory?

    func openLibrary(category: WordCategory?) {
        libraryCategory = category
        selectedTab = .learn
    }
}
