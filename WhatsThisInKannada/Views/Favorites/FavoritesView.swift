import SwiftUI

struct FavoritesView: View {
    let catalog: WordCatalog

    @EnvironmentObject private var session: AppSession
    @EnvironmentObject private var speechOutput: SpeechOutputService
    @EnvironmentObject private var favoritesStore: FavoritesStore

    @State private var isUnlocked = false

    private var savedCount: Int {
        favoritesStore.savedWords.count
    }

    private var practicedCount: Int {
        favoritesStore.savedWords.reduce(0) { $0 + $1.timesPracticed }
    }

    var body: some View {
        NavigationStack {
            Group {
                if isUnlocked {
                    unlockedContent
                } else {
                    lockGate
                }
            }
            .background(StorybookPaperBackground())
            .navigationTitle("Parent")
            .onChange(of: session.selectedTab) { _, tab in
                if tab != .parent {
                    isUnlocked = false
                }
            }
        }
    }

    private var lockGate: some View {
        VStack(spacing: 22) {
            Spacer()

            Image(systemName: "lock.shield.fill")
                .font(.system(size: 54, weight: .black))
                .foregroundStyle(.white)
                .frame(width: 96, height: 96)
                .background(KannadaTheme.peacock, in: Circle())

            VStack(spacing: 8) {
                Text("Parent space")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundStyle(KannadaTheme.ink)

                Text("Hold the button for 2 seconds to open saved words and privacy notes.")
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(KannadaTheme.ink.opacity(0.68))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            Text("Hold to open")
                .font(.headline.weight(.black))
                .foregroundStyle(.white)
                .frame(maxWidth: 280, minHeight: 58)
                .background(KannadaTheme.peacock, in: Capsule())
                .onLongPressGesture(minimumDuration: 2) {
                    isUnlocked = true
                }
                .accessibilityIdentifier("parent-unlock")
                .accessibilityLabel("Hold for two seconds to open parent space")
                .accessibilityAddTraits(.isButton)

            Spacer()
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var unlockedContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header
                localFavorites
                trustStatusGrid
                laterNotes
            }
            .padding(16)
            .padding(.bottom, 96)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                Image(systemName: "lock.open.fill")
                    .font(.system(size: 32, weight: .black))
                    .frame(width: 54, height: 54)
                    .background(.white.opacity(0.18), in: Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text("Saved words")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .lineLimit(1)
                        .minimumScaleFactor(0.76)

                    Text("Favorites stay on this iPhone. Nothing syncs to an account.")
                        .font(.callout.weight(.semibold))
                        .opacity(0.90)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(KannadaTheme.peacock, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
    }

    private var trustStatusGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 148), spacing: 12)], spacing: 12) {
            statusCard(
                icon: "camera.slash.fill",
                title: "No camera",
                detail: "This version has no camera, photo library, or image upload.",
                tint: KannadaTheme.parentBlue
            )
            statusCard(
                icon: "mic.slash.fill",
                title: "No stored speech",
                detail: "Spoken audio is used to find a word, then discarded. It is not saved.",
                tint: KannadaTheme.peacock
            )
            statusCard(
                icon: "externaldrive.fill",
                title: "\(savedCount) local",
                detail: "Saved words use on-device storage only.",
                tint: KannadaTheme.marigold
            )
        }
    }

    private func statusCard(icon: String, title: String, detail: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.title2.weight(.black))
                .foregroundStyle(tint)
                .frame(width: 42, height: 42)
                .background(tint.opacity(0.12), in: Circle())

            Text(title)
                .font(.headline.weight(.black))
                .foregroundStyle(KannadaTheme.ink)
                .lineLimit(2)
                .minimumScaleFactor(0.76)

            Text(detail)
                .font(.caption.weight(.semibold))
                .foregroundStyle(KannadaTheme.ink.opacity(0.62))
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, minHeight: 164, alignment: .topLeading)
        .padding(14)
        .kannadaCard(cornerRadius: 18)
    }

    private var laterNotes: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Later")
                .font(.headline.weight(.black))
                .foregroundStyle(KannadaTheme.ink)

            Text("Mic lock and iCloud backup are not in this version. Voice stays on-device, and favorites do not leave the phone.")
                .font(.callout.weight(.semibold))
                .foregroundStyle(KannadaTheme.ink.opacity(0.62))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .kannadaCard(cornerRadius: 18)
    }

    @ViewBuilder
    private var localFavorites: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Local favorites")
                .font(.headline.weight(.black))
                .foregroundStyle(KannadaTheme.ink)

            if favoritesStore.savedWords.isEmpty {
                emptyFavorites
            } else {
                favoritesSummary
                savedWordsGrid
            }
        }
    }

    private var emptyFavorites: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: "star")
                .font(.title2.weight(.black))
                .foregroundStyle(KannadaTheme.marigold)

            Text("No saved words yet")
                .font(.headline.weight(.black))
                .foregroundStyle(KannadaTheme.ink)

            Text("Save a word from Home or Learn and it will show up here.")
                .font(.callout.weight(.semibold))
                .foregroundStyle(KannadaTheme.ink.opacity(0.62))
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .kannadaCard(cornerRadius: 18)
    }

    private var favoritesSummary: some View {
        HStack(spacing: 10) {
            metricCard(value: "\(savedCount)", label: "saved words", tint: KannadaTheme.peacock)
            metricCard(value: "\(practicedCount)", label: "practice taps", tint: KannadaTheme.marigold)
            metricCard(value: "\(catalog.words.count)", label: "library words", tint: KannadaTheme.parentBlue)
        }
    }

    private func metricCard(value: String, label: String, tint: Color) -> some View {
        VStack(spacing: 5) {
            Text(value)
                .font(.title.weight(.black))
                .foregroundStyle(tint)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(KannadaTheme.ink.opacity(0.52))
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, minHeight: 86)
        .padding(10)
        .kannadaCard(cornerRadius: 18)
    }

    private var savedWordsGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 146), spacing: 14)], spacing: 14) {
            ForEach(favoritesStore.savedWords, id: \.wordID) { saved in
                savedWordCard(saved)
            }
        }
    }

    private func savedWordCard(_ saved: SavedWord) -> some View {
        VStack(spacing: 12) {
            WordIllustrationView(imageName: saved.imageName, category: saved.category, size: 88)

            VStack(spacing: 4) {
                Text(saved.kannada)
                    .font(.title3.weight(.black))
                    .foregroundStyle(KannadaTheme.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Text(saved.english.capitalized)
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(KannadaTheme.ink.opacity(0.54))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)

                Text("\(saved.timesPracticed) practice taps")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(saved.category.themeColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }

            HStack(spacing: 8) {
                Button {
                    speechOutput.speak(saved.kannada, wordID: saved.wordID)
                } label: {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.caption.weight(.black))
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.borderedProminent)
                .tint(KannadaTheme.peacock)
                .accessibilityLabel("Hear \(saved.english)")

                Button(role: .destructive) {
                    favoritesStore.remove(saved)
                } label: {
                    Label("Remove", systemImage: "star.slash")
                        .font(.caption.weight(.black))
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .buttonStyle(.bordered)
                .tint(KannadaTheme.marigold)
                .accessibilityLabel("Remove \(saved.english)")
            }
        }
        .padding(14)
        .kannadaCard(cornerRadius: 20)
    }
}
