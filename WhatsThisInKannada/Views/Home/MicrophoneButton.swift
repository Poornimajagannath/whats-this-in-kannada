import SwiftUI

struct MicrophoneButton: View {
    let isListening: Bool
    var size: CGFloat = 116
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: max(14, size * 0.28), style: .continuous)
                    .fill(isListening ? KannadaTheme.ink : Color.white)
                    .frame(width: size, height: size)
                    .shadow(color: KannadaTheme.ink.opacity(0.16), radius: 12, x: 0, y: 8)

                Image(systemName: isListening ? "stop.fill" : "mic.fill")
                    .font(.system(size: size * 0.36, weight: .bold))
                    .foregroundStyle(isListening ? KannadaTheme.marigold : KannadaTheme.peacock)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isListening ? "Stop listening" : "Start listening")
    }
}
