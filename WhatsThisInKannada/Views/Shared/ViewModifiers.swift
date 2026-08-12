import SwiftUI

enum KannadaTheme {
    static let ink = Color(red: 74 / 255, green: 53 / 255, blue: 38 / 255)
    static let peacock = Color(red: 62 / 255, green: 140 / 255, blue: 124 / 255)
    static let peacockDark = Color(red: 44 / 255, green: 110 / 255, blue: 96 / 255)
    static let marigold = Color(red: 224 / 255, green: 166 / 255, blue: 60 / 255)
    static let card = Color(red: 254 / 255, green: 250 / 255, blue: 241 / 255)
    static let mist = Color(red: 251 / 255, green: 244 / 255, blue: 230 / 255)
    static let parentBlue = Color(red: 74 / 255, green: 53 / 255, blue: 38 / 255)
    static let border = Color(red: 237 / 255, green: 224 / 255, blue: 201 / 255)
    static let blush = Color(red: 217 / 255, green: 154 / 255, blue: 134 / 255)
    static let clay = Color(red: 214 / 255, green: 154 / 255, blue: 116 / 255)

    static func surfaceTint(for category: WordCategory?) -> Color {
        switch category {
        case .family:
            return Color(red: 241 / 255, green: 226 / 255, blue: 214 / 255)
        case .animals:
            return Color(red: 230 / 255, green: 238 / 255, blue: 221 / 255)
        case .fruits:
            return Color(red: 251 / 255, green: 239 / 255, blue: 207 / 255)
        case .none:
            return mist
        }
    }

    static func accent(for category: WordCategory?) -> Color {
        switch category {
        case .family:
            return parentBlue
        case .animals:
            return peacock
        case .fruits:
            return marigold
        case .none:
            return peacock
        }
    }
}

struct DottedMotif: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let step = max(rect.width, rect.height) / 4

        for row in 0...3 {
            for col in 0...3 {
                let point = CGPoint(
                    x: rect.minX + CGFloat(col) * step,
                    y: rect.minY + CGFloat(row) * step
                )
                path.move(to: point)
                path.addLine(to: CGPoint(x: point.x + 0.1, y: point.y))
            }
        }

        return path
    }
}

extension View {
    @ViewBuilder
    func iOSInlineNavigationTitle() -> some View {
        #if os(iOS)
        self.navigationBarTitleDisplayMode(.inline)
        #else
        self
        #endif
    }

    @ViewBuilder
    func toddlerTextInputBehavior() -> some View {
        #if os(iOS)
        self
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .submitLabel(.go)
        #else
        self
        #endif
    }

    func kannadaCard(cornerRadius: CGFloat = 22) -> some View {
        self
            .background(KannadaTheme.card, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(KannadaTheme.border, lineWidth: 1)
            )
            .shadow(color: KannadaTheme.ink.opacity(0.08), radius: 14, x: 0, y: 8)
    }
}

struct StorybookPaperBackground: View {
    var body: some View {
        KannadaTheme.mist
            .overlay {
                Canvas { context, size in
                    let spacing: CGFloat = 28
                    var y: CGFloat = 0

                    while y <= size.height {
                        var x: CGFloat = 0

                        while x <= size.width {
                            let jitter = CGFloat((Int(x + y) % 7) - 3)
                            let rect = CGRect(
                                x: x + jitter,
                                y: y - jitter,
                                width: 1.4,
                                height: 1.4
                            )
                            context.fill(
                                Path(ellipseIn: rect),
                                with: .color(KannadaTheme.ink.opacity(0.045))
                            )
                            x += spacing
                        }

                        y += spacing
                    }
                }
                .allowsHitTesting(false)
            }
    }
}
