import SwiftUI

struct WordDetailView: View {
    let word: KannadaWord

    @EnvironmentObject private var speechOutput: SpeechOutputService
    @EnvironmentObject private var favoritesStore: FavoritesStore

    private var isFavorite: Bool {
        favoritesStore.contains(word.id)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                VStack(spacing: 18) {
                    WordIllustrationView(imageName: word.imageName, category: word.category, size: 206)

                    VStack(spacing: 8) {
                        Text(word.kannada)
                            .font(.system(size: 56, weight: .black, design: .rounded))
                            .foregroundStyle(KannadaTheme.ink)
                            .minimumScaleFactor(0.64)

                        Text(word.transliteration)
                            .font(.title2.weight(.black))
                            .foregroundStyle(KannadaTheme.peacock)

                        Text(word.displayEnglish)
                            .font(.title3.weight(.bold))
                            .foregroundStyle(KannadaTheme.ink.opacity(0.54))
                    }
                    .multilineTextAlignment(.center)
                }
                .padding(22)
                .kannadaCard(cornerRadius: 30)

                HStack(spacing: 12) {
                    Button {
                        speechOutput.speak(word.kannada, wordID: word.id)
                    } label: {
                        Label("ಕೇಳು · Listen", systemImage: "speaker.wave.2.fill")
                            .frame(maxWidth: .infinity, minHeight: 58)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(KannadaTheme.peacock)

                    Button {
                        toggleFavorite()
                    } label: {
                        Image(systemName: isFavorite ? "star.fill" : "star")
                            .font(.title3.weight(.bold))
                            .frame(width: 58, height: 58)
                    }
                    .buttonStyle(.bordered)
                    .tint(KannadaTheme.marigold)
                    .accessibilityLabel(isFavorite ? "Remove favorite" : "Save favorite")
                }

                if !word.aliases.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Also matches")
                            .font(.headline)

                        FlowLayout(items: word.aliases) { alias in
                            Text(alias)
                                .font(.callout.weight(.semibold))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(KannadaTheme.peacock.opacity(0.12), in: Capsule())
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .kannadaCard()
                }
            }
            .padding(20)
        }
        .navigationTitle(word.displayEnglish)
        .iOSInlineNavigationTitle()
        .background(StorybookPaperBackground())
    }

    private func toggleFavorite() {
        favoritesStore.toggle(word)
    }
}

private struct FlowLayout<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    let items: Data
    let content: (Data.Element) -> Content

    init(items: Data, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.items = items
        self.content = content
    }

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 92), spacing: 8)], alignment: .leading, spacing: 8) {
            ForEach(Array(items), id: \.self) { item in
                content(item)
            }
        }
    }
}
