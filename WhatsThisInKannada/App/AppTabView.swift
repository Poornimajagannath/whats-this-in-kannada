import SwiftUI

struct AppTabView: View {
    let catalog: WordCatalog

    var body: some View {
        TabView {
            HomeView(catalog: catalog)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            LibraryView(catalog: catalog)
                .tabItem {
                    Label("Learn", systemImage: "book")
                }

            PracticeView(catalog: catalog)
                .tabItem {
                    Label("Play", systemImage: "play.fill")
                }

            FavoritesView(catalog: catalog)
                .tabItem {
                    Label("Parent", systemImage: "lock.shield.fill")
                }
        }
        .tint(KannadaTheme.peacock)
    }
}
