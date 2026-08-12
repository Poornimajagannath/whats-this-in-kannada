import SwiftUI

struct LibraryView: View {
    private enum LibraryMode: String, CaseIterable, Identifiable {
        case grid = "Grid"
        case browse = "Browse"

        var id: String { rawValue }
    }

    let catalog: WordCatalog

    @EnvironmentObject private var session: AppSession
    @State private var searchText = ""
    @State private var mode: LibraryMode = .grid
    @State private var browseIndex = 0

    private var selectedCategory: WordCategory? {
        session.libraryCategory
    }

    private var filteredWords: [KannadaWord] {
        catalog.search(searchText, category: selectedCategory)
    }

    private var filteredSignature: String {
        filteredWords.map(\.id).joined(separator: "|")
    }

    private var columns: [GridItem] {
        [
            GridItem(.flexible(), spacing: 10),
            GridItem(.flexible(), spacing: 10),
            GridItem(.flexible(), spacing: 10)
        ]
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: mode == .browse ? 12 : 18) {
                    if mode == .grid {
                        header
                    }

                    categoryPicker
                    modePicker

                    if filteredWords.isEmpty {
                        EmptyStateView(
                            systemImage: "magnifyingglass",
                            title: "No words found",
                            message: "Try a family word, animal, or fruit."
                        )
                    } else {
                        switch mode {
                        case .grid:
                            LazyVGrid(columns: columns, spacing: 10) {
                                ForEach(filteredWords) { word in
                                    NavigationLink {
                                        WordDetailView(word: word)
                                    } label: {
                                        WordTileView(word: word, compact: true)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        case .browse:
                            LibraryBrowseView(words: filteredWords, index: $browseIndex)
                        }
                    }
                }
                .padding(16)
                .padding(.bottom, 92)
            }
            .background(StorybookPaperBackground())
            .navigationTitle("Learn")
            .searchable(text: $searchText, prompt: "Search words")
            .onChange(of: filteredSignature) { _, _ in
                browseIndex = 0
            }
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            Image(systemName: selectedCategory?.symbolName ?? "book.fill")
                .font(.title3.weight(.black))
                .foregroundStyle(.white)
                .frame(width: 42, height: 42)
                .background(.white.opacity(0.18), in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(selectedCategory?.kannadaName ?? "ಕಲಿಯೋಣ")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Text("\(selectedCategory?.displayName ?? "All words") · tap a card to open it")
                    .font(.callout.weight(.semibold))
                    .opacity(0.84)
            }

            Spacer()
        }
        .foregroundStyle(.white)
        .padding(18)
        .background(selectedCategory?.themeColor ?? KannadaTheme.peacock, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
    }

    private var categoryPicker: some View {
        HStack(spacing: 8) {
            categoryButton(title: "All", systemImage: "sparkles", isSelected: selectedCategory == nil) {
                session.libraryCategory = nil
            }

            ForEach(WordCategory.allCases) { category in
                categoryButton(title: category.displayName, systemImage: category.symbolName, isSelected: selectedCategory == category) {
                    session.libraryCategory = category
                }
            }
        }
    }

    private var modePicker: some View {
        Picker("Library mode", selection: $mode) {
            ForEach(LibraryMode.allCases) { mode in
                Label(mode.rawValue, systemImage: mode == .grid ? "square.grid.3x3.fill" : "rectangle.on.rectangle")
                    .tag(mode)
            }
        }
        .pickerStyle(.segmented)
    }

    private func categoryButton(title: String, systemImage: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Image(systemName: systemImage)
                    .font(.caption.weight(.black))

                Text(title)
                    .font(.caption2.weight(.black))
                    .lineLimit(1)
                    .minimumScaleFactor(0.65)
            }
            .frame(maxWidth: .infinity, minHeight: 56)
        }
        .buttonStyle(.plain)
        .foregroundStyle(isSelected ? .white : KannadaTheme.ink)
        .background(
            isSelected ? (selectedCategory?.themeColor ?? KannadaTheme.peacock) : KannadaTheme.card,
            in: RoundedRectangle(cornerRadius: 18, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(isSelected ? Color.clear : KannadaTheme.border, lineWidth: 1)
        )
    }
}

private struct LibraryBrowseView: View {
    let words: [KannadaWord]
    @Binding var index: Int

    @EnvironmentObject private var speechOutput: SpeechOutputService
    @EnvironmentObject private var favoritesStore: FavoritesStore

    private var safeIndex: Int {
        guard !words.isEmpty else { return 0 }
        return min(max(index, 0), words.count - 1)
    }

    private var word: KannadaWord? {
        guard !words.isEmpty else { return nil }
        return words[safeIndex]
    }

    var body: some View {
        if let word {
            VStack(spacing: 12) {
                HStack {
                    Text("\(safeIndex + 1) of \(words.count)")
                        .font(.callout.weight(.black))
                        .foregroundStyle(KannadaTheme.ink.opacity(0.58))

                    Spacer()

                    Button {
                        toggleFavorite(word)
                    } label: {
                        Image(systemName: favoritesStore.contains(word.id) ? "star.fill" : "star")
                            .font(.headline.weight(.black))
                            .foregroundStyle(KannadaTheme.marigold)
                            .frame(width: 56, height: 56)
                            .background(KannadaTheme.card, in: Circle())
                            .overlay(Circle().stroke(KannadaTheme.border, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(favoritesStore.contains(word.id) ? "Remove favorite" : "Save favorite")
                }

                VStack(spacing: 6) {
                    WordIllustrationView(imageName: word.imageName, category: word.category, size: 96)

                    VStack(spacing: 4) {
                        Text(word.kannada)
                            .font(.system(size: 34, weight: .black, design: .rounded))
                            .foregroundStyle(KannadaTheme.ink)
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.58)

                        Text(word.transliteration)
                            .font(.title3.weight(.black))
                            .foregroundStyle(KannadaTheme.peacock)

                        Text(word.displayEnglish)
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(KannadaTheme.ink.opacity(0.52))
                    }
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 14)
                .frame(maxWidth: .infinity, minHeight: 214)
                .kannadaCard(cornerRadius: 24)
                .id(word.id)
                .transition(.opacity.combined(with: .scale(scale: 0.98)))

                HStack(spacing: 10) {
                    Button {
                        move(-1)
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.headline.weight(.black))
                            .frame(width: 56, height: 56)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(KannadaTheme.border.opacity(0.80))
                    .foregroundStyle(KannadaTheme.ink)
                    .accessibilityLabel("Previous word")

                    Button {
                        speechOutput.speak(word.kannada, wordID: word.id)
                    } label: {
                        Label("ಕೇಳು · Listen", systemImage: "speaker.wave.2.fill")
                            .font(.headline.weight(.black))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, minHeight: 56)
                            .background(KannadaTheme.peacock, in: Capsule())
                    }
                    .buttonStyle(.plain)

                    Button {
                        move(1)
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.headline.weight(.black))
                            .frame(width: 56, height: 56)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(KannadaTheme.marigold)
                    .foregroundStyle(KannadaTheme.ink)
                    .accessibilityLabel("Next word")
                }
            }
        }
    }

    private func move(_ delta: Int) {
        guard !words.isEmpty else { return }
        withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
            index = (safeIndex + delta + words.count) % words.count
        }
    }

    private func toggleFavorite(_ word: KannadaWord) {
        favoritesStore.toggle(word)
    }
}
