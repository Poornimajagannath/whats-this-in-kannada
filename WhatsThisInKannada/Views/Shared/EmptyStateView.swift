import SwiftUI

struct EmptyStateView: View {
    let systemImage: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: systemImage)
                .font(.system(size: 44, weight: .semibold))
                .foregroundStyle(KannadaTheme.peacock)
                .frame(width: 84, height: 84)
                .background(KannadaTheme.peacock.opacity(0.12), in: Circle())

            Text(title)
                .font(.title3.weight(.bold))
                .foregroundStyle(KannadaTheme.ink)
                .multilineTextAlignment(.center)

            Text(message)
                .font(.body)
                .foregroundStyle(KannadaTheme.ink.opacity(0.60))
                .multilineTextAlignment(.center)
                .lineLimit(nil)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
    }
}
