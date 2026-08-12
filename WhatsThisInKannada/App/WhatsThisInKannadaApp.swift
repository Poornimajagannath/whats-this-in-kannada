import SwiftUI

@main
struct WhatsThisInKannadaApp: App {
    private let catalog = WordCatalog.shared

    @StateObject private var speechOutput = SpeechOutputService()
    @StateObject private var favoritesStore = FavoritesStore()

    var body: some Scene {
        WindowGroup {
            AppTabView(catalog: catalog)
                .environmentObject(speechOutput)
                .environmentObject(favoritesStore)
        }
    }
}
