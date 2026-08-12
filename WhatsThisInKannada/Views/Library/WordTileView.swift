import SwiftUI

struct WordTileView: View {
    let word: KannadaWord
    var compact = false

    var body: some View {
        VStack(spacing: compact ? 8 : 10) {
            WordIllustrationView(imageName: word.imageName, category: word.category, size: compact ? 76 : 96)

            VStack(spacing: 4) {
                Text(word.kannada)
                    .font(compact ? .title3.weight(.black) : .title2.weight(.black))
                    .foregroundStyle(KannadaTheme.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Text(word.transliteration)
                    .font(.caption.weight(.black))
                    .foregroundStyle(KannadaTheme.peacock)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Text(word.displayEnglish)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(KannadaTheme.ink.opacity(0.48))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(KannadaTheme.card, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(KannadaTheme.border, lineWidth: 1)
        )
        .shadow(color: KannadaTheme.ink.opacity(0.05), radius: 12, x: 0, y: 7)
    }
}
