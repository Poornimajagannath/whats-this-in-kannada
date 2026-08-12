import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

struct WordIllustrationView: View {
    let imageName: String
    let category: WordCategory?
    var size: CGFloat = 132

    var body: some View {
        ZStack {
            Circle()
                .fill(KannadaTheme.surfaceTint(for: category))

            if let mascotImage {
                Image(uiImage: mascotImage)
                    .resizable()
                    .scaledToFit()
                    .padding(3)
            } else {
                Circle()
                    .stroke(
                        KannadaTheme.accent(for: category).opacity(0.46),
                        style: StrokeStyle(lineWidth: 2.4, lineCap: .round, dash: [0.5, 7])
                    )
                    .frame(width: 86, height: 86)

                illustration
            }
        }
        .frame(width: 100, height: 100)
        .scaleEffect(size / 100)
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }

    #if canImport(UIKit)
    private var mascotImage: UIImage? {
        guard
            let mascotResourceName,
            let url = Bundle.main.url(forResource: mascotResourceName, withExtension: "png", subdirectory: "mascots")
        else {
            return nil
        }

        return UIImage(contentsOfFile: url.path)
    }
    #else
    private var mascotImage: Never? { nil }
    #endif

    private var mascotResourceName: String? {
        if let exact = exactMascotResourceNames[imageName] {
            return exact
        }

        if imageName.hasPrefix("animal_") {
            return String(imageName.dropFirst("animal_".count))
        }

        if imageName.hasPrefix("fruit_") {
            return String(imageName.dropFirst("fruit_".count))
        }

        return nil
    }

    private var exactMascotResourceNames: [String: String] {
        [
            "animal_elephant": "ele",
            "family_amma": "amma",
            "family_appa": "appa",
            "family_magu": "baby",
            "family_ajji": "ajji",
            "family_taatha": "taatha",
            "family_anna": "boy",
            "family_tamma": "boy",
            "family_son": "boy",
            "family_friend_boy": "boy",
            "family_akka": "girl",
            "family_thangi": "girl",
            "family_daughter": "girl",
            "family_friend_girl": "girl",
            "family_maava": "man",
            "family_chikkappa": "man",
            "family_doddappa": "man",
            "family_atte": "woman",
            "family_chikkamma": "woman",
            "family_doddamma": "woman"
        ]
    }

    @ViewBuilder
    private var illustration: some View {
        if imageName.contains("mango") {
            mango
        } else if imageName.contains("banana") {
            banana
        } else if imageName.contains("apple") {
            apple
        } else if imageName.contains("orange") || imageName.contains("papaya") || imageName.contains("muskmelon") {
            orange
        } else if imageName.contains("grapes") {
            grapes
        } else if imageName.contains("watermelon") {
            watermelon
        } else if imageName.contains("pineapple") || imageName.contains("jackfruit") {
            pineapple
        } else if imageName.contains("elephant") {
            elephant
        } else if imageName.contains("cow") || imageName.contains("buffalo") {
            cow
        } else if imageName.contains("bird") || imageName.contains("duck") || imageName.contains("chicken") {
            bird
        } else if imageName.contains("cat") {
            animalFace(fill: Color(red: 0.95, green: 0.72, blue: 0.43), ear: .triangle)
        } else if imageName.contains("squirrel") {
            squirrel
        } else if imageName.contains("rabbit") {
            rabbit
        } else if imageName.contains("butterfly") {
            butterfly
        } else if imageName.contains("fish") {
            fish
        } else if imageName.contains("frog") {
            frog
        } else if imageName.contains("snake") {
            snake
        } else if imageName.contains("turtle") {
            turtle
        } else if imageName.contains("ant") {
            ant
        } else if imageName.contains("bear") || imageName.contains("monkey") {
            animalFace(fill: Color(red: 0.62, green: 0.42, blue: 0.27), ear: .round)
        } else if imageName.contains("dog") {
            animalFace(fill: Color(red: 0.72, green: 0.50, blue: 0.32), ear: .floppy)
        } else if category == .animals {
            animalFace(fill: Color(red: 0.60, green: 0.72, blue: 0.66), ear: .round)
        } else if category == .family {
            familyPortrait(role: familyRole)
        } else if category == .fruits {
            mango
        } else {
            star
        }
    }

    private var mango: some View {
        ZStack {
            Path { path in
                path.move(to: CGPoint(x: 50, y: 22))
                path.addCurve(to: CGPoint(x: 76, y: 55), control1: CGPoint(x: 68, y: 23), control2: CGPoint(x: 78, y: 39))
                path.addCurve(to: CGPoint(x: 50, y: 83), control1: CGPoint(x: 74, y: 72), control2: CGPoint(x: 62, y: 83))
                path.addCurve(to: CGPoint(x: 24, y: 55), control1: CGPoint(x: 36, y: 83), control2: CGPoint(x: 25, y: 72))
                path.addCurve(to: CGPoint(x: 50, y: 22), control1: CGPoint(x: 22, y: 39), control2: CGPoint(x: 34, y: 23))
            }
            .fill(KannadaTheme.marigold)
            .overlay(
                Path { path in
                    path.move(to: CGPoint(x: 50, y: 22))
                    path.addCurve(to: CGPoint(x: 76, y: 55), control1: CGPoint(x: 68, y: 23), control2: CGPoint(x: 78, y: 39))
                    path.addCurve(to: CGPoint(x: 50, y: 83), control1: CGPoint(x: 74, y: 72), control2: CGPoint(x: 62, y: 83))
                    path.addCurve(to: CGPoint(x: 24, y: 55), control1: CGPoint(x: 36, y: 83), control2: CGPoint(x: 25, y: 72))
                    path.addCurve(to: CGPoint(x: 50, y: 22), control1: CGPoint(x: 22, y: 39), control2: CGPoint(x: 34, y: 23))
                }
                .stroke(KannadaTheme.ink, lineWidth: 3)
            )

            Ellipse()
                .fill(.white.opacity(0.28))
                .frame(width: 16, height: 28)
                .rotationEffect(.degrees(-14))
                .offset(x: -11, y: -6)

            leaf
                .offset(x: -7, y: -37)
        }
    }

    private var banana: some View {
        ZStack {
            Path { path in
                path.move(to: CGPoint(x: 28, y: 25))
                path.addCurve(to: CGPoint(x: 58, y: 86), control1: CGPoint(x: 13, y: 45), control2: CGPoint(x: 20, y: 76))
                path.addCurve(to: CGPoint(x: 72, y: 73), control1: CGPoint(x: 68, y: 88), control2: CGPoint(x: 77, y: 80))
                path.addCurve(to: CGPoint(x: 46, y: 25), control1: CGPoint(x: 40, y: 60), control2: CGPoint(x: 37, y: 42))
                path.addCurve(to: CGPoint(x: 28, y: 25), control1: CGPoint(x: 48, y: 18), control2: CGPoint(x: 34, y: 19))
            }
            .fill(KannadaTheme.marigold)
            .overlay(
                Path { path in
                    path.move(to: CGPoint(x: 28, y: 25))
                    path.addCurve(to: CGPoint(x: 58, y: 86), control1: CGPoint(x: 13, y: 45), control2: CGPoint(x: 20, y: 76))
                    path.addCurve(to: CGPoint(x: 72, y: 73), control1: CGPoint(x: 68, y: 88), control2: CGPoint(x: 77, y: 80))
                    path.addCurve(to: CGPoint(x: 46, y: 25), control1: CGPoint(x: 40, y: 60), control2: CGPoint(x: 37, y: 42))
                    path.addCurve(to: CGPoint(x: 28, y: 25), control1: CGPoint(x: 48, y: 18), control2: CGPoint(x: 34, y: 19))
                }
                .stroke(KannadaTheme.ink, lineWidth: 3)
            )

            Path { path in
                path.move(to: CGPoint(x: 37, y: 31))
                path.addCurve(to: CGPoint(x: 59, y: 80), control1: CGPoint(x: 28, y: 50), control2: CGPoint(x: 34, y: 69))
            }
            .stroke(.white.opacity(0.34), lineWidth: 7)

            Circle().fill(Color(red: 0.38, green: 0.25, blue: 0.13)).frame(width: 10, height: 10).offset(x: -23, y: -25)
            Circle().fill(Color(red: 0.38, green: 0.25, blue: 0.13)).frame(width: 10, height: 10).offset(x: 9, y: 35)
        }
    }

    private var apple: some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.91, green: 0.22, blue: 0.17))
                .frame(width: 58, height: 58)
                .offset(y: 8)
                .overlay(Circle().stroke(KannadaTheme.ink, lineWidth: 3).offset(y: 8))

            Ellipse()
                .fill(.white.opacity(0.28))
                .frame(width: 12, height: 20)
                .rotationEffect(.degrees(-20))
                .offset(x: -14, y: -3)

            stem
                .offset(y: -29)

            leaf
                .offset(x: 11, y: -33)
        }
    }

    private var orange: some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.94, green: 0.47, blue: 0.13))
                .frame(width: 58, height: 58)
                .overlay(Circle().stroke(KannadaTheme.ink, lineWidth: 3))

            ForEach(0..<6) { index in
                Rectangle()
                    .fill(KannadaTheme.ink.opacity(0.18))
                    .frame(width: 2, height: 25)
                    .offset(y: -12)
                    .rotationEffect(.degrees(Double(index) * 60))
            }

            Circle()
                .fill(Color(red: 0.79, green: 0.41, blue: 0))
                .frame(width: 17, height: 17)

            leaf
                .offset(x: 10, y: -31)
        }
    }

    private var grapes: some View {
        ZStack {
            ForEach(0..<9) { index in
                Circle()
                    .fill(Color(red: 0.45, green: 0.33, blue: 0.70))
                    .frame(width: 20, height: 20)
                    .overlay(Circle().stroke(KannadaTheme.ink, lineWidth: 2))
                    .offset(grapeOffset(index))
            }

            stem.offset(y: -34)
            leaf.offset(x: 12, y: -35)
        }
    }

    private var watermelon: some View {
        ZStack {
            SemiCircle()
                .fill(Color(red: 0.95, green: 0.27, blue: 0.28))
                .frame(width: 70, height: 42)
                .overlay(SemiCircle().stroke(Color(red: 0.08, green: 0.50, blue: 0.30), lineWidth: 8))
                .overlay(SemiCircle().stroke(KannadaTheme.ink, lineWidth: 2.5))
                .offset(y: 13)

            ForEach([-16, 0, 16], id: \.self) { x in
                Capsule()
                    .fill(KannadaTheme.ink)
                    .frame(width: 4, height: 8)
                    .rotationEffect(.degrees(15))
                    .offset(x: CGFloat(x), y: 16)
            }
        }
    }

    private var pineapple: some View {
        ZStack {
            Ellipse()
                .fill(KannadaTheme.marigold)
                .frame(width: 48, height: 62)
                .overlay(Ellipse().stroke(KannadaTheme.ink, lineWidth: 3))
                .offset(y: 10)

            ForEach([-14, 0, 14], id: \.self) { x in
                leaf.offset(x: CGFloat(x), y: -31).rotationEffect(.degrees(Double(x)))
            }

            ForEach(-1...1, id: \.self) { row in
                ForEach(-1...1, id: \.self) { col in
                    Circle()
                        .fill(KannadaTheme.ink.opacity(0.24))
                        .frame(width: 4, height: 4)
                        .offset(x: CGFloat(col * 12), y: CGFloat(row * 12 + 12))
                }
            }
        }
    }

    private var elephant: some View {
        ZStack {
            Ellipse().fill(Color(red: 0.43, green: 0.78, blue: 0.74)).frame(width: 28, height: 34).offset(x: -29, y: -5)
            Ellipse().fill(Color(red: 0.43, green: 0.78, blue: 0.74)).frame(width: 28, height: 34).offset(x: 29, y: -5)

            Circle()
                .fill(Color(red: 0.66, green: 0.85, blue: 0.83))
                .frame(width: 58, height: 58)
                .overlay(Circle().stroke(KannadaTheme.ink, lineWidth: 3))
                .offset(y: -2)

            Path { path in
                path.move(to: CGPoint(x: 46, y: 58))
                path.addCurve(to: CGPoint(x: 31, y: 70), control1: CGPoint(x: 39, y: 68), control2: CGPoint(x: 28, y: 67))
                path.addCurve(to: CGPoint(x: 43, y: 70), control1: CGPoint(x: 31, y: 78), control2: CGPoint(x: 40, y: 77))
            }
            .stroke(KannadaTheme.ink, lineWidth: 5)

            cuteEyes(color: KannadaTheme.peacock).offset(y: -7)
            smile.offset(y: 10)
        }
    }

    private var cow: some View {
        ZStack {
            horn.offset(x: -19, y: -31)
            horn.scaleEffect(x: -1, y: 1).offset(x: 19, y: -31)
            animalFace(fill: .white, ear: .round)
            Ellipse().fill(Color(red: 0.78, green: 0.60, blue: 0.42)).frame(width: 18, height: 16).offset(x: -10, y: -14)
            Ellipse().fill(KannadaTheme.blush.opacity(0.8)).frame(width: 28, height: 19).overlay(Ellipse().stroke(KannadaTheme.ink, lineWidth: 1.6)).offset(y: 11)
        }
    }

    private var bird: some View {
        ZStack {
            ForEach([-30, -15, 0, 15, 30], id: \.self) { rotation in
                Ellipse()
                    .fill(rotation == 0 ? Color(red: 0.12, green: 0.44, blue: 0.69) : KannadaTheme.peacock)
                    .frame(width: 16, height: 35)
                    .overlay(Ellipse().stroke(KannadaTheme.ink, lineWidth: 1.6))
                    .rotationEffect(.degrees(Double(rotation)))
                    .offset(y: -17)
            }

            Ellipse().fill(KannadaTheme.peacockDark).frame(width: 38, height: 45).overlay(Ellipse().stroke(KannadaTheme.ink, lineWidth: 3)).offset(y: 16)
            Circle().fill(KannadaTheme.peacock).frame(width: 34, height: 34).overlay(Circle().stroke(KannadaTheme.ink, lineWidth: 3)).offset(y: -5)
            Triangle().fill(KannadaTheme.marigold).frame(width: 17, height: 13).rotationEffect(.degrees(-90)).offset(x: -24, y: -4)
            Circle().fill(.white).frame(width: 12, height: 12).offset(x: 8, y: -8)
            Circle().fill(KannadaTheme.ink).frame(width: 6, height: 6).offset(x: 9, y: -8)
        }
    }

    private var rabbit: some View {
        ZStack {
            Ellipse()
                .fill(Color(red: 0.98, green: 0.93, blue: 0.86))
                .frame(width: 18, height: 44)
                .overlay(Ellipse().stroke(KannadaTheme.ink, lineWidth: 2.1))
                .rotationEffect(.degrees(-12))
                .offset(x: -16, y: -30)

            Ellipse()
                .fill(Color(red: 0.98, green: 0.93, blue: 0.86))
                .frame(width: 18, height: 44)
                .overlay(Ellipse().stroke(KannadaTheme.ink, lineWidth: 2.1))
                .rotationEffect(.degrees(12))
                .offset(x: 16, y: -30)

            animalFace(fill: Color(red: 0.98, green: 0.93, blue: 0.86), ear: .round)
            Circle().fill(KannadaTheme.blush.opacity(0.6)).frame(width: 8, height: 8).offset(y: 5)
        }
    }

    private var butterfly: some View {
        ZStack {
            Ellipse()
                .fill(KannadaTheme.blush)
                .frame(width: 36, height: 48)
                .overlay(Ellipse().stroke(KannadaTheme.ink, lineWidth: 2.3))
                .rotationEffect(.degrees(-32))
                .offset(x: -21, y: -8)

            Ellipse()
                .fill(KannadaTheme.marigold)
                .frame(width: 36, height: 48)
                .overlay(Ellipse().stroke(KannadaTheme.ink, lineWidth: 2.3))
                .rotationEffect(.degrees(32))
                .offset(x: 21, y: -8)

            Ellipse()
                .fill(Color(red: 0.92, green: 0.72, blue: 0.50))
                .frame(width: 28, height: 34)
                .overlay(Ellipse().stroke(KannadaTheme.ink, lineWidth: 2))
                .rotationEffect(.degrees(28))
                .offset(x: -15, y: 20)

            Ellipse()
                .fill(Color(red: 0.87, green: 0.63, blue: 0.40))
                .frame(width: 28, height: 34)
                .overlay(Ellipse().stroke(KannadaTheme.ink, lineWidth: 2))
                .rotationEffect(.degrees(-28))
                .offset(x: 15, y: 20)

            Capsule()
                .fill(KannadaTheme.peacockDark)
                .frame(width: 10, height: 58)
                .overlay(Capsule().stroke(KannadaTheme.ink, lineWidth: 2))
                .offset(y: 5)

            Path { path in
                path.move(to: CGPoint(x: 47, y: 25))
                path.addQuadCurve(to: CGPoint(x: 34, y: 13), control: CGPoint(x: 38, y: 16))
                path.move(to: CGPoint(x: 53, y: 25))
                path.addQuadCurve(to: CGPoint(x: 66, y: 13), control: CGPoint(x: 62, y: 16))
            }
            .stroke(KannadaTheme.ink, lineWidth: 2.1)

            Circle().fill(KannadaTheme.marigold).frame(width: 5, height: 5).offset(x: -16, y: -36)
            Circle().fill(KannadaTheme.marigold).frame(width: 5, height: 5).offset(x: 16, y: -36)
        }
    }

    private var fish: some View {
        ZStack {
            Triangle()
                .fill(KannadaTheme.marigold)
                .frame(width: 30, height: 32)
                .overlay(Triangle().stroke(KannadaTheme.ink, lineWidth: 2.2))
                .rotationEffect(.degrees(90))
                .offset(x: 33, y: 3)

            Ellipse()
                .fill(KannadaTheme.peacock)
                .frame(width: 62, height: 42)
                .overlay(Ellipse().stroke(KannadaTheme.ink, lineWidth: 3))
                .offset(x: -4, y: 2)

            Triangle()
                .fill(KannadaTheme.marigold)
                .frame(width: 18, height: 14)
                .rotationEffect(.degrees(-90))
                .offset(x: -39, y: 2)

            Circle().fill(.white).frame(width: 12, height: 12).overlay(Circle().stroke(KannadaTheme.ink, lineWidth: 1.2)).offset(x: -20, y: -7)
            Circle().fill(KannadaTheme.ink).frame(width: 5, height: 5).offset(x: -19, y: -7)

            Path { path in
                path.move(to: CGPoint(x: 44, y: 54))
                path.addQuadCurve(to: CGPoint(x: 57, y: 54), control: CGPoint(x: 50, y: 59))
            }
            .stroke(KannadaTheme.ink, lineWidth: 1.8)
        }
    }

    private var frog: some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.58, green: 0.74, blue: 0.48))
                .frame(width: 24, height: 24)
                .overlay(Circle().stroke(KannadaTheme.ink, lineWidth: 2))
                .offset(x: -20, y: -24)

            Circle()
                .fill(Color(red: 0.58, green: 0.74, blue: 0.48))
                .frame(width: 24, height: 24)
                .overlay(Circle().stroke(KannadaTheme.ink, lineWidth: 2))
                .offset(x: 20, y: -24)

            Circle()
                .fill(Color(red: 0.62, green: 0.78, blue: 0.52))
                .frame(width: 62, height: 54)
                .overlay(Circle().stroke(KannadaTheme.ink, lineWidth: 3))
                .offset(y: 2)

            cuteEyes(color: KannadaTheme.ink).offset(y: -23)
            smile.offset(y: 14)
            Ellipse().fill(KannadaTheme.blush.opacity(0.45)).frame(width: 13, height: 8).offset(x: -22, y: 8)
            Ellipse().fill(KannadaTheme.blush.opacity(0.45)).frame(width: 13, height: 8).offset(x: 22, y: 8)
        }
    }

    private var snake: some View {
        ZStack {
            Path { path in
                path.move(to: CGPoint(x: 22, y: 62))
                path.addCurve(to: CGPoint(x: 45, y: 36), control1: CGPoint(x: 16, y: 42), control2: CGPoint(x: 34, y: 31))
                path.addCurve(to: CGPoint(x: 71, y: 56), control1: CGPoint(x: 58, y: 43), control2: CGPoint(x: 47, y: 65))
                path.addCurve(to: CGPoint(x: 78, y: 38), control1: CGPoint(x: 84, y: 51), control2: CGPoint(x: 83, y: 42))
            }
            .stroke(Color(red: 0.48, green: 0.70, blue: 0.40), style: StrokeStyle(lineWidth: 16, lineCap: .round, lineJoin: .round))

            Path { path in
                path.move(to: CGPoint(x: 22, y: 62))
                path.addCurve(to: CGPoint(x: 45, y: 36), control1: CGPoint(x: 16, y: 42), control2: CGPoint(x: 34, y: 31))
                path.addCurve(to: CGPoint(x: 71, y: 56), control1: CGPoint(x: 58, y: 43), control2: CGPoint(x: 47, y: 65))
                path.addCurve(to: CGPoint(x: 78, y: 38), control1: CGPoint(x: 84, y: 51), control2: CGPoint(x: 83, y: 42))
            }
            .stroke(KannadaTheme.ink, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))

            Circle().fill(.white).frame(width: 8, height: 8).overlay(Circle().stroke(KannadaTheme.ink, lineWidth: 1)).offset(x: 29, y: -16)
            Circle().fill(KannadaTheme.ink).frame(width: 3, height: 3).offset(x: 30, y: -16)
            Path { path in
                path.move(to: CGPoint(x: 82, y: 38))
                path.addLine(to: CGPoint(x: 91, y: 34))
                path.move(to: CGPoint(x: 82, y: 38))
                path.addLine(to: CGPoint(x: 91, y: 42))
            }
            .stroke(KannadaTheme.blush, lineWidth: 1.8)
        }
    }

    private var turtle: some View {
        ZStack {
            Circle().fill(Color(red: 0.48, green: 0.70, blue: 0.40)).frame(width: 18, height: 18).overlay(Circle().stroke(KannadaTheme.ink, lineWidth: 2)).offset(x: -38, y: 0)
            ForEach([-22, 22], id: \.self) { x in
                Circle().fill(Color(red: 0.48, green: 0.70, blue: 0.40)).frame(width: 15, height: 15).overlay(Circle().stroke(KannadaTheme.ink, lineWidth: 1.8)).offset(x: CGFloat(x), y: -24)
                Circle().fill(Color(red: 0.48, green: 0.70, blue: 0.40)).frame(width: 15, height: 15).overlay(Circle().stroke(KannadaTheme.ink, lineWidth: 1.8)).offset(x: CGFloat(x), y: 24)
            }

            Ellipse()
                .fill(KannadaTheme.peacock)
                .frame(width: 64, height: 50)
                .overlay(Ellipse().stroke(KannadaTheme.ink, lineWidth: 3))

            Path { path in
                path.move(to: CGPoint(x: 34, y: 50))
                path.addLine(to: CGPoint(x: 50, y: 30))
                path.addLine(to: CGPoint(x: 66, y: 50))
                path.addLine(to: CGPoint(x: 50, y: 70))
                path.closeSubpath()
            }
            .stroke(KannadaTheme.ink.opacity(0.28), lineWidth: 2)
        }
    }

    private var ant: some View {
        ZStack {
            ForEach([30, 50, 70], id: \.self) { x in
                Circle()
                    .fill(x == 30 ? KannadaTheme.ink : Color(red: 0.52, green: 0.30, blue: 0.20))
                    .frame(width: x == 70 ? 26 : 22, height: x == 70 ? 26 : 22)
                    .overlay(Circle().stroke(KannadaTheme.ink, lineWidth: 1.7))
                    .offset(x: CGFloat(x - 50), y: 0)
            }

            ForEach([-1, 0, 1], id: \.self) { row in
                Path { path in
                    path.move(to: CGPoint(x: 42, y: 50))
                    path.addLine(to: CGPoint(x: 25, y: 50 + CGFloat(row * 14)))
                    path.move(to: CGPoint(x: 58, y: 50))
                    path.addLine(to: CGPoint(x: 75, y: 50 + CGFloat(row * 14)))
                }
                .stroke(KannadaTheme.ink, lineWidth: 2)
            }

            Path { path in
                path.move(to: CGPoint(x: 28, y: 43))
                path.addQuadCurve(to: CGPoint(x: 18, y: 31), control: CGPoint(x: 18, y: 37))
                path.move(to: CGPoint(x: 30, y: 43))
                path.addQuadCurve(to: CGPoint(x: 24, y: 28), control: CGPoint(x: 32, y: 34))
            }
            .stroke(KannadaTheme.ink, lineWidth: 1.8)
        }
    }

    private var squirrel: some View {
        ZStack {
            SquirrelTail()
                .fill(Color(red: 0.74, green: 0.48, blue: 0.28))
                .frame(width: 50, height: 68)
                .overlay(
                    SquirrelTail()
                        .stroke(KannadaTheme.ink, lineWidth: 2.6)
                        .frame(width: 50, height: 68)
                )
                .offset(x: -19, y: -2)

            Ellipse()
                .fill(Color(red: 0.80, green: 0.54, blue: 0.34))
                .frame(width: 38, height: 48)
                .overlay(Ellipse().stroke(KannadaTheme.ink, lineWidth: 2.4))
                .offset(x: 9, y: 16)

            Ellipse()
                .fill(Color(red: 0.95, green: 0.81, blue: 0.60))
                .frame(width: 18, height: 26)
                .offset(x: 8, y: 21)

            Circle()
                .fill(Color(red: 0.82, green: 0.56, blue: 0.36))
                .frame(width: 35, height: 35)
                .overlay(Circle().stroke(KannadaTheme.ink, lineWidth: 2.4))
                .offset(x: 14, y: -13)

            Triangle()
                .fill(Color(red: 0.82, green: 0.56, blue: 0.36))
                .frame(width: 16, height: 16)
                .overlay(Triangle().stroke(KannadaTheme.ink, lineWidth: 1.8))
                .rotationEffect(.degrees(-18))
                .offset(x: 4, y: -36)

            Triangle()
                .fill(Color(red: 0.82, green: 0.56, blue: 0.36))
                .frame(width: 16, height: 16)
                .overlay(Triangle().stroke(KannadaTheme.ink, lineWidth: 1.8))
                .rotationEffect(.degrees(22))
                .offset(x: 27, y: -35)

            cuteEyes(color: KannadaTheme.peacockDark)
                .scaleEffect(0.62)
                .offset(x: 15, y: -16)

            Circle()
                .fill(KannadaTheme.ink)
                .frame(width: 6, height: 5)
                .offset(x: 30, y: -9)

            smile
                .scaleEffect(0.55)
                .offset(x: 14, y: -4)

            Capsule()
                .fill(KannadaTheme.ink.opacity(0.22))
                .frame(width: 24, height: 3)
                .rotationEffect(.degrees(-14))
                .offset(x: -20, y: -4)
        }
    }

    private enum EarStyle {
        case round
        case triangle
        case floppy
    }

    private enum FamilyRole {
        case amma
        case appa
        case baby
        case ajji
        case taatha
        case boy
        case girl
        case man
        case woman
    }

    private var familyRole: FamilyRole {
        if imageName.contains("amma") { return .amma }
        if imageName.contains("appa") { return .appa }
        if imageName.contains("magu") { return .baby }
        if imageName.contains("ajji") { return .ajji }
        if imageName.contains("taatha") { return .taatha }
        if imageName.contains("anna") || imageName.contains("tamma") || imageName.contains("son") || imageName.contains("friend_boy") { return .boy }
        if imageName.contains("akka") || imageName.contains("thangi") || imageName.contains("daughter") || imageName.contains("friend_girl") { return .girl }
        if imageName.contains("maava") || imageName.contains("chikkappa") || imageName.contains("doddappa") { return .man }
        if imageName.contains("atte") || imageName.contains("chikkamma") || imageName.contains("doddamma") { return .woman }
        return .boy
    }

    private func animalFace(fill: Color, ear: EarStyle) -> some View {
        ZStack {
            switch ear {
            case .round:
                Circle().fill(fill).frame(width: 24, height: 24).overlay(Circle().stroke(KannadaTheme.ink, lineWidth: 2)).offset(x: -24, y: -24)
                Circle().fill(fill).frame(width: 24, height: 24).overlay(Circle().stroke(KannadaTheme.ink, lineWidth: 2)).offset(x: 24, y: -24)
            case .triangle:
                Triangle().fill(fill).frame(width: 26, height: 24).overlay(Triangle().stroke(KannadaTheme.ink, lineWidth: 2)).offset(x: -23, y: -27)
                Triangle().fill(fill).frame(width: 26, height: 24).overlay(Triangle().stroke(KannadaTheme.ink, lineWidth: 2)).offset(x: 23, y: -27)
            case .floppy:
                Ellipse().fill(fill.opacity(0.92)).frame(width: 20, height: 34).overlay(Ellipse().stroke(KannadaTheme.ink, lineWidth: 2)).rotationEffect(.degrees(18)).offset(x: -28, y: -12)
                Ellipse().fill(fill.opacity(0.92)).frame(width: 20, height: 34).overlay(Ellipse().stroke(KannadaTheme.ink, lineWidth: 2)).rotationEffect(.degrees(-18)).offset(x: 28, y: -12)
            }

            Circle()
                .fill(fill)
                .frame(width: 58, height: 58)
                .overlay(Circle().stroke(KannadaTheme.ink, lineWidth: 3))

            cuteEyes(color: KannadaTheme.ink)
            Ellipse().fill(KannadaTheme.blush.opacity(0.4)).frame(width: 12, height: 8).offset(x: -19, y: 8)
            Ellipse().fill(KannadaTheme.blush.opacity(0.4)).frame(width: 12, height: 8).offset(x: 19, y: 8)
            smile.offset(y: 12)
        }
    }

    private func familyPortrait(role: FamilyRole) -> some View {
        ZStack {
            switch role {
            case .amma:
                motherAndBaby
            case .appa:
                familyPerson(
                    shirt: KannadaTheme.peacock,
                    hair: .cap,
                    accessory: .none,
                    scale: 1.0
                )
            case .baby:
                babyPortrait
            case .ajji:
                familyPerson(
                    shirt: Color(red: 0.73, green: 0.38, blue: 0.24),
                    hair: .bun,
                    accessory: .glasses,
                    scale: 0.98
                )
            case .taatha:
                familyPerson(
                    shirt: Color(red: 0.33, green: 0.51, blue: 0.47),
                    hair: .sideGray,
                    accessory: .glasses,
                    scale: 0.98
                )
            case .boy:
                familyPerson(
                    shirt: KannadaTheme.peacock,
                    hair: .short,
                    accessory: .none,
                    scale: 0.92
                )
            case .girl:
                familyPerson(
                    shirt: KannadaTheme.clay,
                    hair: .pigtails,
                    accessory: .bindi,
                    scale: 0.92
                )
            case .man:
                familyPerson(
                    shirt: KannadaTheme.marigold,
                    hair: .cap,
                    accessory: .collar,
                    scale: 0.98
                )
            case .woman:
                familyPerson(
                    shirt: KannadaTheme.clay,
                    hair: .pigtails,
                    accessory: .bindi,
                    scale: 0.98
                )
            }
        }
    }

    private enum HairStyle {
        case short
        case cap
        case pigtails
        case bun
        case sideGray
    }

    private enum FamilyAccessory {
        case none
        case bindi
        case glasses
        case collar
    }

    private func familyPerson(
        shirt: Color,
        hair: HairStyle,
        accessory: FamilyAccessory,
        scale: CGFloat
    ) -> some View {
        ZStack {
            familyTorso(fill: shirt)
                .scaleEffect(scale)
                .offset(y: 19)

            if hair == .pigtails {
                Ellipse()
                    .fill(KannadaTheme.ink)
                    .frame(width: 13, height: 32)
                    .rotationEffect(.degrees(9))
                    .offset(x: -23, y: -1)
                Ellipse()
                    .fill(KannadaTheme.ink)
                    .frame(width: 13, height: 32)
                    .rotationEffect(.degrees(-9))
                    .offset(x: 23, y: -1)
            }

            familyHead
                .offset(y: -13)

            familyHair(style: hair)
                .offset(y: -13)

            cuteEyes(color: KannadaTheme.ink)
                .scaleEffect(0.55)
                .offset(y: -14)

            smile
                .scaleEffect(0.58)
                .offset(y: -3)

            switch accessory {
            case .none:
                EmptyView()
            case .bindi:
                Circle()
                    .fill(KannadaTheme.marigold)
                    .frame(width: 7, height: 7)
                    .overlay(Circle().stroke(KannadaTheme.ink, lineWidth: 1))
                    .offset(y: -30)
            case .glasses:
                glasses
                    .offset(y: -14)
            case .collar:
                Path { path in
                    path.move(to: CGPoint(x: 43, y: 56))
                    path.addLine(to: CGPoint(x: 50, y: 65))
                    path.addLine(to: CGPoint(x: 57, y: 56))
                }
                .stroke(KannadaTheme.ink, lineWidth: 1.8)
            }
        }
    }

    private var motherAndBaby: some View {
        ZStack {
            familyPerson(
                shirt: KannadaTheme.clay,
                hair: .bun,
                accessory: .bindi,
                scale: 0.92
            )
            .offset(x: -9, y: 1)

            ZStack {
                familyTorso(fill: KannadaTheme.marigold)
                    .scaleEffect(0.56)
                    .offset(y: 18)

                familyHead
                    .scaleEffect(0.58)
                    .offset(y: -4)

                cuteEyes(color: KannadaTheme.ink)
                    .scaleEffect(0.32)
                    .offset(y: -4)

                smile
                    .scaleEffect(0.34)
                    .offset(y: 2)
            }
            .offset(x: 18, y: 18)
        }
    }

    private var babyPortrait: some View {
        ZStack {
            Ellipse()
                .fill(KannadaTheme.marigold)
                .frame(width: 42, height: 34)
                .overlay(Ellipse().stroke(KannadaTheme.ink, lineWidth: 2.2))
                .offset(y: 25)

            familyHead
                .scaleEffect(1.1)
                .offset(y: -7)

            Path { path in
                path.move(to: CGPoint(x: 51, y: 26))
                path.addQuadCurve(to: CGPoint(x: 48, y: 15), control: CGPoint(x: 55, y: 19))
            }
            .stroke(KannadaTheme.ink, lineWidth: 1.7)

            cuteEyes(color: KannadaTheme.ink)
                .scaleEffect(0.56)
                .offset(y: -8)

            smile
                .scaleEffect(0.60)
                .offset(y: 3)
        }
    }

    private var familyHead: some View {
        Circle()
            .fill(KannadaTheme.clay)
            .frame(width: 36, height: 36)
            .overlay(Circle().stroke(KannadaTheme.ink, lineWidth: 2.4))
    }

    private func familyTorso(fill: Color) -> some View {
        Path { path in
            path.move(to: CGPoint(x: 32, y: 83))
            path.addLine(to: CGPoint(x: 68, y: 83))
            path.addLine(to: CGPoint(x: 64, y: 58))
            path.addQuadCurve(to: CGPoint(x: 36, y: 58), control: CGPoint(x: 50, y: 51))
            path.closeSubpath()
        }
        .fill(fill)
        .overlay(
            Path { path in
                path.move(to: CGPoint(x: 32, y: 83))
                path.addLine(to: CGPoint(x: 68, y: 83))
                path.addLine(to: CGPoint(x: 64, y: 58))
                path.addQuadCurve(to: CGPoint(x: 36, y: 58), control: CGPoint(x: 50, y: 51))
                path.closeSubpath()
            }
            .stroke(KannadaTheme.ink, lineWidth: 2.4)
        )
    }

    @ViewBuilder
    private func familyHair(style: HairStyle) -> some View {
        switch style {
        case .short:
            Path { path in
                path.move(to: CGPoint(x: 35, y: 38))
                path.addQuadCurve(to: CGPoint(x: 65, y: 38), control: CGPoint(x: 50, y: 22))
                path.addLine(to: CGPoint(x: 64, y: 45))
                path.addQuadCurve(to: CGPoint(x: 36, y: 45), control: CGPoint(x: 50, y: 36))
                path.closeSubpath()
            }
            .fill(KannadaTheme.ink)
        case .cap:
            Path { path in
                path.move(to: CGPoint(x: 34, y: 36))
                path.addQuadCurve(to: CGPoint(x: 66, y: 38), control: CGPoint(x: 50, y: 24))
                path.addLine(to: CGPoint(x: 64, y: 43))
                path.addQuadCurve(to: CGPoint(x: 36, y: 42), control: CGPoint(x: 50, y: 36))
                path.closeSubpath()
            }
            .fill(KannadaTheme.ink.opacity(0.95))
            Capsule()
                .fill(KannadaTheme.marigold)
                .frame(width: 26, height: 4)
                .rotationEffect(.degrees(2))
                .offset(y: -14)
        case .pigtails:
            Path { path in
                path.move(to: CGPoint(x: 35, y: 38))
                path.addQuadCurve(to: CGPoint(x: 65, y: 38), control: CGPoint(x: 50, y: 23))
                path.addQuadCurve(to: CGPoint(x: 36, y: 44), control: CGPoint(x: 50, y: 38))
                path.closeSubpath()
            }
            .fill(KannadaTheme.ink)
        case .bun:
            Circle()
                .fill(KannadaTheme.ink)
                .frame(width: 14, height: 14)
                .offset(y: -25)
            Path { path in
                path.move(to: CGPoint(x: 35, y: 37))
                path.addQuadCurve(to: CGPoint(x: 65, y: 38), control: CGPoint(x: 50, y: 22))
                path.addQuadCurve(to: CGPoint(x: 36, y: 45), control: CGPoint(x: 50, y: 38))
                path.closeSubpath()
            }
            .fill(KannadaTheme.ink)
        case .sideGray:
            Path { path in
                path.move(to: CGPoint(x: 34, y: 39))
                path.addQuadCurve(to: CGPoint(x: 66, y: 39), control: CGPoint(x: 50, y: 25))
                path.addQuadCurve(to: CGPoint(x: 36, y: 47), control: CGPoint(x: 50, y: 40))
                path.closeSubpath()
            }
            .fill(Color(red: 0.82, green: 0.75, blue: 0.66))
        }
    }

    private var glasses: some View {
        HStack(spacing: 3) {
            Circle()
                .stroke(KannadaTheme.ink, lineWidth: 1.6)
                .frame(width: 13, height: 13)
            Circle()
                .stroke(KannadaTheme.ink, lineWidth: 1.6)
                .frame(width: 13, height: 13)
        }
    }

    private var star: some View {
        Star()
            .fill(KannadaTheme.marigold)
            .frame(width: 62, height: 62)
            .overlay(Star().stroke(KannadaTheme.ink, lineWidth: 3))
    }

    private var cuteEyes: some View {
        cuteEyes(color: KannadaTheme.ink)
    }

    private func cuteEyes(color: Color) -> some View {
        HStack(spacing: 14) {
            Circle().fill(.white).frame(width: 13, height: 13).overlay(Circle().stroke(KannadaTheme.ink, lineWidth: 1.2))
                .overlay(Circle().fill(color).frame(width: 7, height: 7))
            Circle().fill(.white).frame(width: 13, height: 13).overlay(Circle().stroke(KannadaTheme.ink, lineWidth: 1.2))
                .overlay(Circle().fill(color).frame(width: 7, height: 7))
        }
    }

    private var smile: some View {
        Path { path in
            path.move(to: CGPoint(x: 43, y: 52))
            path.addQuadCurve(to: CGPoint(x: 57, y: 52), control: CGPoint(x: 50, y: 59))
        }
        .stroke(KannadaTheme.ink, lineWidth: 2.2)
    }

    private var leaf: some View {
        Ellipse()
            .fill(Color(red: 0.23, green: 0.70, blue: 0.29))
            .frame(width: 21, height: 10)
            .overlay(Ellipse().stroke(KannadaTheme.ink, lineWidth: 2))
            .rotationEffect(.degrees(-28))
    }

    private var stem: some View {
        Capsule()
            .fill(Color(red: 0.39, green: 0.29, blue: 0.17))
            .frame(width: 6, height: 18)
            .rotationEffect(.degrees(15))
    }

    private var horn: some View {
        Path { path in
            path.move(to: CGPoint(x: 36, y: 28))
            path.addCurve(to: CGPoint(x: 22, y: 23), control1: CGPoint(x: 29, y: 12), control2: CGPoint(x: 20, y: 15))
            path.addCurve(to: CGPoint(x: 36, y: 28), control1: CGPoint(x: 26, y: 22), control2: CGPoint(x: 31, y: 24))
        }
        .fill(KannadaTheme.marigold)
        .overlay(
            Path { path in
                path.move(to: CGPoint(x: 36, y: 28))
                path.addCurve(to: CGPoint(x: 22, y: 23), control1: CGPoint(x: 29, y: 12), control2: CGPoint(x: 20, y: 15))
                path.addCurve(to: CGPoint(x: 36, y: 28), control1: CGPoint(x: 26, y: 22), control2: CGPoint(x: 31, y: 24))
            }
            .stroke(KannadaTheme.ink, lineWidth: 2)
        )
    }

    private func grapeOffset(_ index: Int) -> CGSize {
        let positions: [CGSize] = [
            CGSize(width: -12, height: -17),
            CGSize(width: 12, height: -17),
            CGSize(width: -24, height: 0),
            CGSize(width: 0, height: 0),
            CGSize(width: 24, height: 0),
            CGSize(width: -12, height: 17),
            CGSize(width: 12, height: 17),
            CGSize(width: 0, height: 33),
            CGSize(width: 0, height: -33)
        ]
        return positions[index]
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

private struct SemiCircle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(
            center: CGPoint(x: rect.midX, y: rect.maxY),
            radius: rect.width / 2,
            startAngle: .degrees(180),
            endAngle: .degrees(0),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

private struct Star: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * 0.45
        var path = Path()

        for point in 0..<10 {
            let radius = point.isMultiple(of: 2) ? outerRadius : innerRadius
            let angle = Double(point) * 36 - 90
            let x = center.x + CGFloat(cos(angle * .pi / 180)) * radius
            let y = center.y + CGFloat(sin(angle * .pi / 180)) * radius

            if point == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }

        path.closeSubpath()
        return path
    }
}

private struct SquirrelTail: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.maxX * 0.72, y: rect.maxY * 0.91))
        path.addCurve(
            to: CGPoint(x: rect.minX + rect.width * 0.22, y: rect.maxY * 0.66),
            control1: CGPoint(x: rect.maxX * 0.34, y: rect.maxY * 0.92),
            control2: CGPoint(x: rect.minX + rect.width * 0.12, y: rect.maxY * 0.80)
        )
        path.addCurve(
            to: CGPoint(x: rect.minX + rect.width * 0.54, y: rect.maxY * 0.08),
            control1: CGPoint(x: rect.minX + rect.width * 0.36, y: rect.maxY * 0.48),
            control2: CGPoint(x: rect.minX + rect.width * 0.12, y: rect.maxY * 0.18)
        )
        path.addCurve(
            to: CGPoint(x: rect.maxX * 0.90, y: rect.maxY * 0.46),
            control1: CGPoint(x: rect.maxX * 0.88, y: rect.minY),
            control2: CGPoint(x: rect.maxX * 1.06, y: rect.maxY * 0.23)
        )
        path.addCurve(
            to: CGPoint(x: rect.maxX * 0.72, y: rect.maxY * 0.91),
            control1: CGPoint(x: rect.maxX * 0.72, y: rect.maxY * 0.61),
            control2: CGPoint(x: rect.maxX * 0.92, y: rect.maxY * 0.80)
        )
        path.closeSubpath()
        return path
    }
}
