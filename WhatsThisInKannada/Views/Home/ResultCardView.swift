import SwiftUI

struct ResultCardView: View {
    let result: LookupResult
    let isFavorite: Bool
    let isSpeaking: Bool
    let onSpeak: () -> Void
    let onFavorite: () -> Void
    var onTryAnother: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 20) {
            WordIllustrationView(imageName: result.imageName, category: result.category, size: 188)
                .padding(.top, 8)

            VStack(spacing: 8) {
                Text(result.kannada)
                    .font(.system(size: result.source == .unknown ? 30 : 48, weight: .black, design: .rounded))
                    .foregroundStyle(KannadaTheme.ink)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.62)

                if !result.transliteration.isEmpty {
                    Text(result.transliteration)
                        .font(.title3.weight(.black))
                        .foregroundStyle(KannadaTheme.peacock)
                        .minimumScaleFactor(0.7)
                }

                Text(result.english.capitalized)
                    .font(.headline)
                    .foregroundStyle(KannadaTheme.ink.opacity(0.55))
            }
            .frame(maxWidth: .infinity)

            if let message = result.message {
                Text(message)
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(KannadaTheme.ink.opacity(0.58))
                    .multilineTextAlignment(.center)
            }

            HStack(spacing: 12) {
                Button(action: onSpeak) {
                    Label(isSpeaking ? "ಕೇಳುತ್ತಿದೆ" : "ಕೇಳು · Listen", systemImage: isSpeaking ? "speaker.wave.2.fill" : "speaker.wave.2")
                        .frame(maxWidth: .infinity, minHeight: 56)
                }
                .buttonStyle(.borderedProminent)
                .tint(KannadaTheme.peacock)
                .disabled(!result.canSpeak)
                .accessibilityLabel(isSpeaking ? "Speaking" : "Listen")

                Button(action: onFavorite) {
                    Image(systemName: isFavorite ? "star.fill" : "star")
                        .font(.title3.weight(.bold))
                        .frame(width: 58, height: 56)
                }
                .buttonStyle(.bordered)
                .tint(KannadaTheme.marigold)
                .disabled(!result.canFavorite)
                .accessibilityLabel(isFavorite ? "Remove favorite" : "Save favorite")
            }

            if let onTryAnother {
                Button(action: onTryAnother) {
                    Label("Try another", systemImage: "arrow.counterclockwise")
                        .font(.headline.weight(.black))
                        .frame(maxWidth: .infinity, minHeight: 52)
                }
                .buttonStyle(.bordered)
                .tint(KannadaTheme.ink)
                .accessibilityLabel("Try another word")
            }
        }
        .padding(20)
        .kannadaCard(cornerRadius: 28)
    }
}
