import SwiftUI

struct FavoritesView: View {
    let catalog: WordCatalog

    @EnvironmentObject private var favoritesStore: FavoritesStore

    private var savedCount: Int {
        favoritesStore.savedWords.count
    }

    private var practicedCount: Int {
        favoritesStore.savedWords.reduce(0) { $0 + $1.timesPracticed }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    trustStatusGrid
                    plannedControls
                    dataNotes
                    localFavorites
                }
                .padding(16)
                .padding(.bottom, 96)
            }
            .background(StorybookPaperBackground())
            .navigationTitle("Parent")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 32, weight: .black))
                    .frame(width: 54, height: 54)
                    .background(.white.opacity(0.18), in: Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text("Parent trust gate")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .lineLimit(1)
                        .minimumScaleFactor(0.76)

                    Text("V1 keeps learning local and parent-owned.")
                        .font(.callout.weight(.semibold))
                        .opacity(0.90)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Text("No camera is used in this release. Voice input is not saved as audio. Favorites stay on this device.")
                .font(.footnote.weight(.bold))
                .opacity(0.86)
                .fixedSize(horizontal: false, vertical: true)
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
                detail: "V1 has no camera capture, photo roll access, or image upload.",
                tint: KannadaTheme.parentBlue
            )

            statusCard(
                icon: "mic.slash.fill",
                title: "No stored speech",
                detail: "The app does not save voice recordings or keep spoken audio by default.",
                tint: KannadaTheme.peacock
            )

            statusCard(
                icon: "externaldrive.fill",
                title: "\(savedCount) local",
                detail: "Saved words use local device storage. Nothing syncs to an account in V1.",
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

    private var plannedControls: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(
                title: "Parent Controls",
                subtitle: "Visible gates for V1 review. These controls are planned and disabled."
            )

            plannedControlRow(
                icon: "mic.fill",
                title: "Mic lock planned",
                detail: "Not active in V1. Today, the Home mic asks iOS permission and uses on-device speech only.",
                tint: KannadaTheme.peacock
            )

            plannedControlRow(
                icon: "icloud.fill",
                title: "Cloud sync",
                detail: "Planned: opt-in backup only after parent consent. Off in V1.",
                tint: KannadaTheme.parentBlue
            )
        }
    }

    private func plannedControlRow(icon: String, title: String, detail: String, tint: Color) -> some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: icon)
                .font(.headline.weight(.black))
                .foregroundStyle(tint)
                .frame(width: 38, height: 38)
                .background(tint.opacity(0.12), in: Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.callout.weight(.black))
                    .foregroundStyle(KannadaTheme.ink)

                Text(detail)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(KannadaTheme.ink.opacity(0.62))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 8)

            Toggle("", isOn: .constant(false))
                .labelsHidden()
                .disabled(true)
                .tint(tint)
                .accessibilityLabel("\(title) planned")
        }
        .padding(14)
        .kannadaCard(cornerRadius: 18)
    }

    private var dataNotes: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(
                title: "Data Notes",
                subtitle: "What parents own and what V1 does not collect."
            )

            noteRow(
                icon: "person.crop.circle.badge.checkmark",
                title: "Parent-owned progress",
                detail: "\(savedCount) saved words and \(practicedCount) practice taps are stored on this device for the parent to review.",
                tint: KannadaTheme.marigold
            )

            noteRow(
                icon: "text.bubble.fill",
                title: "Typed and spoken prompts",
                detail: "Prompts are used to find a Kannada word during the session. They are not added to the saved list unless a parent saves the result.",
                tint: KannadaTheme.peacock
            )

            noteRow(
                icon: "trash.fill",
                title: "Local delete",
                detail: "Removing a favorite deletes that saved word from this device's local list.",
                tint: KannadaTheme.blush
            )
        }
    }

    private func noteRow(icon: String, title: String, detail: String, tint: Color) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.headline.weight(.black))
                .foregroundStyle(tint)
                .frame(width: 36, height: 36)
                .background(tint.opacity(0.12), in: Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.callout.weight(.black))
                    .foregroundStyle(KannadaTheme.ink)

                Text(detail)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(KannadaTheme.ink.opacity(0.62))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .kannadaCard(cornerRadius: 18)
    }

    @ViewBuilder
    private var localFavorites: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(
                title: "Local Favorites",
                subtitle: "Saved words remain on this device."
            )

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

            Text("No local favorites yet")
                .font(.headline.weight(.black))
                .foregroundStyle(KannadaTheme.ink)

            Text("When a parent saves words from Home or Learn, they appear here. V1 keeps this list on the device.")
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

            Button(role: .destructive) {
                favoritesStore.remove(saved)
            } label: {
                Label("Remove", systemImage: "star.slash")
                    .font(.caption.weight(.black))
                    .frame(maxWidth: .infinity, minHeight: 38)
            }
            .buttonStyle(.bordered)
            .tint(KannadaTheme.marigold)
            .accessibilityLabel("Remove \(saved.english)")
        }
        .padding(14)
        .kannadaCard(cornerRadius: 20)
    }

    private func sectionHeader(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline.weight(.black))
                .foregroundStyle(KannadaTheme.ink)

            Text(subtitle)
                .font(.caption.weight(.semibold))
                .foregroundStyle(KannadaTheme.ink.opacity(0.58))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
