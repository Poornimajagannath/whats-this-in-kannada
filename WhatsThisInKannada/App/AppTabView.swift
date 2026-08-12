import SwiftUI

struct AppTabView: View {
    let catalog: WordCatalog

    @EnvironmentObject private var session: AppSession

    var body: some View {
        TabView(selection: $session.selectedTab) {
            HomeView(catalog: catalog)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(AppTab.home)
                .accessibilityLabel("Home")

            LibraryView(catalog: catalog)
                .tabItem {
                    Label("Learn", systemImage: "book")
                }
                .tag(AppTab.learn)
                .accessibilityLabel("Learn")

            PracticeView(catalog: catalog)
                .tabItem {
                    Label("Play", systemImage: "play.fill")
                }
                .tag(AppTab.play)
                .accessibilityLabel("Play")

            FavoritesView(catalog: catalog)
                .tabItem {
                    Label("Parent", systemImage: "lock.shield.fill")
                }
                .tag(AppTab.parent)
                .accessibilityLabel("Parent")
        }
        .tint(KannadaTheme.peacock)
    }
}
