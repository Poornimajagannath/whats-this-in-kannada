import SwiftUI

struct PracticeView: View {
    enum Mode: String, CaseIterable, Identifiable {
        case flashcards = "Flashcards"
        case quiz = "Quiz"
        case walk = "Walk"

        var id: String { rawValue }
    }

    let catalog: WordCatalog

    @EnvironmentObject private var favoritesStore: FavoritesStore
    @State private var mode: Mode = .flashcards
    @State private var completedIDs: Set<String> = []

    private var practiceWords: [KannadaWord] {
        let favoriteIDs = Set(favoritesStore.savedWords.map(\.wordID))
        let favorites = catalog.words.filter { favoriteIDs.contains($0.id) }
        return favorites.isEmpty ? Array(catalog.words.prefix(18)) : favorites
    }

    private var progress: Double {
        PracticeEngine.progress(completed: completedIDs.count, total: practiceWords.count)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                playHeader

                Picker("Practice mode", selection: $mode) {
                    ForEach(Mode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)

                if practiceWords.isEmpty {
                    EmptyStateView(
                        systemImage: "sparkles",
                        title: "No practice words",
                        message: "Add words to the library seed to practice."
                    )
                } else {
                    switch mode {
                    case .flashcards:
                        FlashcardPracticeView(words: practiceWords, completedIDs: $completedIDs)
                    case .quiz:
                        QuizPracticeView(words: practiceWords, completedIDs: $completedIDs)
                    case .walk:
                        ObjectWalkPracticeView(words: practiceWords, completedIDs: $completedIDs)
                    }
                }
            }
            .padding(.top, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(StorybookPaperBackground())
            .navigationTitle("Play")
            .onChange(of: mode) { _, _ in
                completedIDs = []
            }
        }
    }

    private var playHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(headerTitle)
                        .font(.title2.weight(.black))
                    Text(headerSubtitle)
                        .font(.callout.weight(.semibold))
                        .opacity(0.78)
                }

                Spacer()

                Text("\(completedIDs.count)/\(max(practiceWords.count, 1))")
                    .font(.headline.weight(.black))
                    .padding(.horizontal, 12)
                    .frame(height: 36)
                    .background(.white.opacity(0.16), in: Capsule())
                    .accessibilityIdentifier("practice-count")
                    .accessibilityLabel("\(completedIDs.count) of \(practiceWords.count) words practiced")
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(.white.opacity(0.18))
                    Capsule()
                        .fill(KannadaTheme.marigold)
                        .frame(width: proxy.size.width * progress)
                }
            }
            .frame(height: 6)
            .accessibilityLabel("Practice progress")
        }
        .foregroundStyle(.white)
        .padding(18)
        .background(KannadaTheme.parentBlue, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
        .padding(.horizontal, 16)
    }

    private var headerTitle: String {
        switch mode {
        case .flashcards:
            "ಆಟ · Flashcards"
        case .quiz:
            "ಆಟ · Quiz"
        case .walk:
            "ಆಟ · Object walk"
        }
    }

    private var headerSubtitle: String {
        switch mode {
        case .flashcards:
            "See the picture, then reveal Kannada"
        case .quiz:
            "Look at the picture, tap the Kannada word"
        case .walk:
            "Find it, hear it, say it, match it"
        }
    }
}

private struct FlashcardPracticeView: View {
    let words: [KannadaWord]
    @Binding var completedIDs: Set<String>

    @EnvironmentObject private var speechOutput: SpeechOutputService
    @State private var index = 0
    @State private var showingAnswer = false

    private var word: KannadaWord {
        words[PracticeEngine.flashcardIndex(current: index, count: words.count, delta: 0)]
    }

    var body: some View {
        VStack(spacing: 18) {
            VStack(spacing: 18) {
                WordIllustrationView(imageName: word.imageName, category: word.category, size: 170)

                Text(showingAnswer ? word.kannada : word.displayEnglish)
                    .font(.system(size: showingAnswer ? 52 : 40, weight: .black, design: .rounded))
                    .foregroundStyle(KannadaTheme.ink)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.62)

                if showingAnswer {
                    Text(word.transliteration)
                        .font(.title2.weight(.black))
                        .foregroundStyle(KannadaTheme.peacock)
                }
            }
            .padding(22)
            .frame(maxWidth: .infinity, minHeight: 360)
            .kannadaCard(cornerRadius: 28)
            .padding(.horizontal, 16)
            .accessibilityElement(children: .combine)
            .accessibilityIdentifier("flashcard")
            .accessibilityLabel(showingAnswer ? "\(word.displayEnglish), \(word.kannada), \(word.transliteration)" : word.displayEnglish)

            HStack(spacing: 12) {
                Button {
                    move(-1)
                } label: {
                    Image(systemName: "arrow.left")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(KannadaTheme.ink)
                        .frame(width: 58, height: 56)
                        .background(KannadaTheme.border.opacity(0.80), in: Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Previous card")

                Button {
                    showingAnswer.toggle()
                    if showingAnswer {
                        completedIDs.insert(word.id)
                        speechOutput.speak(word.kannada, wordID: word.id)
                    }
                } label: {
                    Label(showingAnswer ? "Hide" : "Show", systemImage: showingAnswer ? "eye.slash" : "eye")
                        .font(.headline.weight(.black))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, minHeight: 56)
                        .background(KannadaTheme.peacock, in: Capsule())
                }
                .buttonStyle(.plain)

                Button {
                    move(1)
                } label: {
                    Image(systemName: "arrow.right")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(KannadaTheme.ink)
                        .frame(width: 58, height: 56)
                        .background(KannadaTheme.marigold.opacity(0.35), in: Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Next card")
            }
            .padding(.horizontal, 16)
        }
        .onChange(of: words.map(\.id).joined(separator: "|")) { _, _ in
            index = 0
            showingAnswer = false
        }
    }

    private func move(_ delta: Int) {
        index = PracticeEngine.flashcardIndex(current: index, count: words.count, delta: delta)
        showingAnswer = false
    }
}

private struct QuizPracticeView: View {
    let words: [KannadaWord]
    @Binding var completedIDs: Set<String>

    @EnvironmentObject private var speechOutput: SpeechOutputService
    @State private var prompt: KannadaWord?
    @State private var choices: [KannadaWord] = []
    @State private var selectedID: String?

    private var wordSignature: String {
        words.map(\.id).joined(separator: "|")
    }

    var body: some View {
        VStack(spacing: 18) {
            if let prompt {
                VStack(spacing: 16) {
                    WordIllustrationView(imageName: prompt.imageName, category: prompt.category, size: 156)

                    VStack(spacing: 4) {
                        Text("ಯಾವುದು?")
                            .font(.system(.largeTitle, design: .rounded, weight: .black))
                            .foregroundStyle(KannadaTheme.ink)

                        Text("Which Kannada word matches this picture?")
                            .font(.callout.weight(.semibold))
                            .foregroundStyle(KannadaTheme.ink.opacity(0.54))
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity)
                .kannadaCard(cornerRadius: 26)
                .padding(.horizontal, 16)
                .accessibilityElement(children: .combine)
                .accessibilityIdentifier("quiz-prompt")
                .accessibilityLabel("Quiz picture for a \(prompt.category.displayName) word")

                VStack(spacing: 10) {
                    ForEach(choices) { choice in
                        Button {
                            selectedID = choice.id
                            if PracticeEngine.isCorrect(choiceID: choice.id, promptID: prompt.id) {
                                completedIDs.insert(prompt.id)
                                speechOutput.speak(choice.kannada, wordID: choice.id)
                            }
                        } label: {
                            HStack {
                                Text(choice.kannada)
                                    .font(.title2.weight(.black))
                                    .foregroundStyle(KannadaTheme.ink)

                                Spacer()

                                Text(choice.transliteration)
                                    .font(.callout.weight(.semibold))
                                    .foregroundStyle(KannadaTheme.ink.opacity(0.54))
                            }
                            .padding(.horizontal, 16)
                            .frame(minHeight: 64)
                            .background(buttonBackground(for: choice, prompt: prompt), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(KannadaTheme.border, lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(selectedID != nil)
                        .accessibilityLabel(choice.transliteration)
                    }
                }
                .padding(.horizontal, 16)

                Button {
                    makeRound()
                } label: {
                    Label(selectedID == nil ? "Skip" : "Next", systemImage: "arrow.clockwise")
                        .frame(maxWidth: .infinity, minHeight: 56)
                }
                .buttonStyle(.borderedProminent)
                .tint(KannadaTheme.marigold)
                .foregroundStyle(KannadaTheme.ink)
                .padding(.horizontal, 16)
            }
        }
        .onAppear(perform: makeRound)
        .onChange(of: wordSignature) { _, _ in
            makeRound()
        }
    }

    private func buttonBackground(for choice: KannadaWord, prompt: KannadaWord) -> Color {
        guard let selectedID else { return KannadaTheme.card }
        if choice.id == prompt.id {
            return KannadaTheme.peacock.opacity(0.20)
        }
        if choice.id == selectedID {
            return Color.red.opacity(0.16)
        }
        return KannadaTheme.card
    }

    private func makeRound() {
        guard let round = PracticeEngine.makeQuizRound(from: words) else {
            prompt = nil
            choices = []
            selectedID = nil
            return
        }
        prompt = round.prompt
        choices = round.choices
        selectedID = nil
    }
}

private struct ObjectWalkPracticeView: View {
    private enum LadderStep: Int, CaseIterable, Identifiable {
        case look
        case hear
        case say
        case find
        case done

        var id: Int { rawValue }

        var title: String {
            switch self {
            case .look: "Look"
            case .hear: "Hear"
            case .say: "Say"
            case .find: "Find"
            case .done: "Done"
            }
        }

        var systemImage: String {
            switch self {
            case .look: "eye.fill"
            case .hear: "speaker.wave.2.fill"
            case .say: "mouth.fill"
            case .find: "hand.tap.fill"
            case .done: "star.fill"
            }
        }
    }

    let words: [KannadaWord]
    @Binding var completedIDs: Set<String>

    @EnvironmentObject private var speechOutput: SpeechOutputService
    @EnvironmentObject private var favoritesStore: FavoritesStore
    @State private var index = 0
    @State private var ladderStep: LadderStep = .look
    @State private var choices: [KannadaWord] = []
    @State private var selectedID: String?

    private var safeIndex: Int {
        guard !words.isEmpty else { return 0 }
        return min(max(index, 0), words.count - 1)
    }

    private var word: KannadaWord? {
        guard !words.isEmpty else { return nil }
        return words[safeIndex]
    }

    private var wordSignature: String {
        words.map(\.id).joined(separator: "|")
    }

    private var columns: [GridItem] {
        [
            GridItem(.flexible(), spacing: 10),
            GridItem(.flexible(), spacing: 10)
        ]
    }

    var body: some View {
        ScrollView {
            if let word {
                VStack(spacing: 14) {
                    ladderHeader
                    objectCard(for: word)

                    switch ladderStep {
                    case .look:
                        primaryAction(title: "I found it", systemImage: "eye.fill", color: KannadaTheme.peacock) {
                            ladderStep = .hear
                        }
                    case .hear:
                        primaryAction(title: "ಕೇಳು · Hear", systemImage: "speaker.wave.2.fill", color: KannadaTheme.peacock) {
                            speechOutput.speak(word.kannada, wordID: word.id)
                            ladderStep = .say
                        }
                    case .say:
                        sayBackCard(for: word)
                    case .find:
                        findCard(for: word)
                    case .done:
                        doneCard(for: word)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
            }
        }
        .scrollIndicators(.hidden)
        .onAppear(perform: resetRound)
        .onChange(of: wordSignature) { _, _ in
            index = 0
            completedIDs = []
            if let firstWord = words.first {
                resetRound(for: firstWord)
            }
        }
    }

    private var ladderHeader: some View {
        HStack(spacing: 7) {
            ForEach(LadderStep.allCases) { step in
                VStack(spacing: 4) {
                    Image(systemName: step.systemImage)
                        .font(.caption.weight(.black))
                    Text(step.title)
                        .font(.caption2.weight(.black))
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                }
                .foregroundStyle(isActiveOrComplete(step) ? .white : KannadaTheme.ink.opacity(0.62))
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(
                    isActiveOrComplete(step) ? KannadaTheme.peacock : KannadaTheme.card,
                    in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(isActiveOrComplete(step) ? Color.clear : KannadaTheme.border, lineWidth: 1)
                )
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Step \(ladderStep.title)")
    }

    private func objectCard(for word: KannadaWord) -> some View {
        VStack(spacing: 12) {
            HStack {
                Label("\(safeIndex + 1) of \(words.count)", systemImage: word.category.symbolName)
                    .font(.callout.weight(.black))
                    .foregroundStyle(KannadaTheme.ink.opacity(0.62))

                Spacer()

                Button {
                    favoritesStore.toggle(word)
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

            WordIllustrationView(imageName: word.imageName, category: word.category, size: 142)

            VStack(spacing: 5) {
                Text("Find: \(word.displayEnglish)")
                    .font(.system(.largeTitle, design: .rounded, weight: .black))
                    .foregroundStyle(KannadaTheme.ink)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.58)

                if ladderStep.rawValue >= LadderStep.hear.rawValue {
                    Text(word.kannada)
                        .font(.system(.largeTitle, design: .rounded, weight: .black))
                        .foregroundStyle(KannadaTheme.ink)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.52)

                    Text(word.transliteration)
                        .font(.title3.weight(.black))
                        .foregroundStyle(KannadaTheme.peacock)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.7)
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, minHeight: 318)
        .kannadaCard(cornerRadius: 28)
    }

    private func sayBackCard(for word: KannadaWord) -> some View {
        VStack(spacing: 12) {
            Text("Say it with your grown-up")
                .font(.headline.weight(.black))
                .foregroundStyle(KannadaTheme.ink)

            Text(word.transliteration)
                .font(.system(.largeTitle, design: .rounded, weight: .black))
                .foregroundStyle(KannadaTheme.peacock)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.58)

            primaryAction(
                title: "I said it",
                systemImage: "mouth.fill",
                color: KannadaTheme.marigold,
                foregroundColor: KannadaTheme.ink
            ) {
                ladderStep = .find
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .background(KannadaTheme.surfaceTint(for: word.category), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private func findCard(for word: KannadaWord) -> some View {
        VStack(spacing: 12) {
            Text("Tap the matching picture")
                .font(.headline.weight(.black))
                .foregroundStyle(KannadaTheme.ink)

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(choices) { choice in
                    Button {
                        selectedID = choice.id
                        if PracticeEngine.isCorrect(choiceID: choice.id, promptID: word.id) {
                            completedIDs.insert(word.id)
                            favoritesStore.markPracticed(wordID: word.id, learned: true)
                            speechOutput.speak(word.kannada, wordID: word.id)
                            ladderStep = .done
                        }
                    } label: {
                        VStack(spacing: 8) {
                            WordIllustrationView(imageName: choice.imageName, category: choice.category, size: 74)
                            Text(choice.displayEnglish)
                                .font(.caption.weight(.bold))
                                .foregroundStyle(KannadaTheme.ink.opacity(0.56))
                                .lineLimit(1)
                                .minimumScaleFactor(0.62)
                        }
                        .frame(maxWidth: .infinity, minHeight: 132)
                        .padding(.vertical, 10)
                        .background(choiceBackground(choice, prompt: word), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .stroke(choice.id == selectedID ? KannadaTheme.peacock.opacity(0.55) : KannadaTheme.border, lineWidth: 1.5)
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(choice.displayEnglish)
                }
            }

            if selectedID != nil, selectedID != word.id {
                Text("Try that tap again")
                    .font(.callout.weight(.black))
                    .foregroundStyle(KannadaTheme.blush)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .kannadaCard(cornerRadius: 24)
    }

    private func doneCard(for word: KannadaWord) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "star.fill")
                .font(.title.weight(.black))
                .foregroundStyle(KannadaTheme.marigold)

            Text("You found \(word.kannada)")
                .font(.system(size: 30, weight: .black, design: .rounded))
                .foregroundStyle(KannadaTheme.ink)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.6)

            HStack(spacing: 10) {
                Button {
                    speechOutput.speak(word.kannada, wordID: word.id)
                } label: {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.headline.weight(.black))
                        .foregroundStyle(.white)
                        .frame(width: 58, height: 56)
                        .background(KannadaTheme.peacock, in: Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Hear word again")

                primaryAction(
                    title: nextTitle,
                    systemImage: "arrow.right",
                    color: KannadaTheme.marigold,
                    foregroundColor: KannadaTheme.ink
                ) {
                    moveToNextWord()
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .kannadaCard(cornerRadius: 24)
    }

    private func primaryAction(
        title: String,
        systemImage: String,
        color: Color,
        foregroundColor: Color = .white,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.headline.weight(.black))
                .foregroundStyle(foregroundColor)
                .frame(maxWidth: .infinity, minHeight: 58)
                .background(color, in: Capsule())
        }
        .buttonStyle(.plain)
    }

    private var nextTitle: String {
        completedIDs.count >= words.count ? "Walk again" : "Next object"
    }

    private func isActiveOrComplete(_ step: LadderStep) -> Bool {
        step.rawValue <= ladderStep.rawValue
    }

    private func choiceBackground(_ choice: KannadaWord, prompt: KannadaWord) -> Color {
        guard let selectedID else { return KannadaTheme.card }
        if choice.id == prompt.id {
            return KannadaTheme.peacock.opacity(0.22)
        }
        if choice.id == selectedID {
            return KannadaTheme.blush.opacity(0.22)
        }
        return KannadaTheme.card
    }

    private func resetRound() {
        guard let word else { return }
        resetRound(for: word)
    }

    private func resetRound(for word: KannadaWord) {
        ladderStep = .look
        selectedID = nil
        let round = PracticeEngine.makeQuizRound(prompt: word, from: words)
        choices = round.choices
    }

    private func moveToNextWord() {
        guard !words.isEmpty else { return }
        let nextWord: KannadaWord

        if completedIDs.count >= words.count {
            completedIDs = []
            index = 0
            nextWord = words[0]
        } else {
            var nextIndex = (safeIndex + 1) % words.count
            while completedIDs.contains(words[nextIndex].id), nextIndex != safeIndex {
                nextIndex = (nextIndex + 1) % words.count
            }
            index = nextIndex
            nextWord = words[nextIndex]
        }

        resetRound(for: nextWord)
    }
}
