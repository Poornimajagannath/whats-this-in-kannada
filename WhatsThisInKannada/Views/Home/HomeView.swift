import SwiftUI

struct HomeView: View {
    let catalog: WordCatalog

    @EnvironmentObject private var session: AppSession
    @EnvironmentObject private var speechOutput: SpeechOutputService
    @EnvironmentObject private var favoritesStore: FavoritesStore
    @StateObject private var speechService = SpeechService()

    @State private var typedText = ""
    @State private var result: LookupResult?
    @State private var suggestions: [KannadaWord] = []
    @State private var isResolving = false
    @State private var lastResolvedTranscript = ""
    @State private var selectedTinyWorldID: String?

    var body: some View {
        NavigationStack {
            ZStack {
                StorybookPaperBackground().ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 14) {
                        header
                        listenPanel
                            .padding(.top, -42)
                            .zIndex(1)

                        if let result {
                            ResultCardView(
                                result: result,
                                isFavorite: isFavorite(result),
                                isSpeaking: speechOutput.speakingWordID == result.wordID,
                                onSpeak: { speechOutput.speak(result.kannada, wordID: result.wordID) },
                                onFavorite: { toggleFavorite(result) },
                                onTryAnother: clearResult
                            )
                            .transition(.scale.combined(with: .opacity))

                            if result.source == .unknown, !suggestions.isEmpty {
                                suggestionRow
                            }
                        } else {
                            tinyWorldPrompt
                            categoryCards
                            starterWords
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 108)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .onChange(of: speechService.isListening) { _, isListening in
                guard !isListening else { return }
                let transcript = speechService.transcript.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !transcript.isEmpty, transcript != lastResolvedTranscript else { return }
                lastResolvedTranscript = transcript
                Task { await resolve(transcript) }
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(alignment: .leading, spacing: 5) {
                Text("ಕನ್ನಡ ಕಲಿ")
                    .font(.callout.weight(.black))
                    .opacity(0.88)

                Text("ನಮಸ್ಕಾರ, ಪುಟ್ಟಿ!")
                    .font(.system(size: 31, weight: .black, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Text("Shall we read and learn today?")
                    .font(.callout.weight(.semibold))
                    .opacity(0.90)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 4)

            VStack(spacing: 8) {
                WordIllustrationView(imageName: "animal_squirrel", category: .animals, size: 54)
                    .background(Color.white.opacity(0.28), in: Circle())

                HStack(spacing: 5) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(KannadaTheme.marigold)
                    Text("\(favoritesStore.savedWords.count)")
                        .font(.caption.weight(.black))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .frame(height: 28)
                .background(.white.opacity(0.18), in: Capsule())
            }
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 56)
        .padding(.horizontal, 18)
        .padding(.bottom, 62)
        .background {
            ZStack(alignment: .topTrailing) {
                KannadaTheme.peacock
                DottedMotif()
                    .stroke(.white.opacity(0.22), style: StrokeStyle(lineWidth: 4, lineCap: .round, dash: [0.1, 12]))
                    .frame(width: 88, height: 88)
                    .offset(x: 34, y: 24)
            }
            .clipShape(UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: 32, bottomTrailingRadius: 32, topTrailingRadius: 0, style: .continuous))
        }
        .padding(.horizontal, -16)
    }

    private var listenPanel: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 14) {
                MicrophoneButton(isListening: speechService.isListening, size: 52) {
                    handleMicrophoneTap()
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("ಇದು ಏನು?")
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundStyle(KannadaTheme.ink)

                    Text("Say a word · hear its Kannada name")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(KannadaTheme.ink.opacity(0.74))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.headline.weight(.black))
                    .foregroundStyle(KannadaTheme.ink.opacity(0.42))
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(voicePrompt)
                    .font(.callout.weight(.bold))
                    .foregroundStyle(KannadaTheme.ink)

                if !speechService.transcript.isEmpty {
                    Text(speechService.transcript)
                        .font(.body.weight(.medium))
                        .foregroundStyle(KannadaTheme.ink.opacity(0.72))
                        .multilineTextAlignment(.leading)
                }

                if let error = speechService.errorMessage {
                    Text(error)
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(.red)
                }
            }

            HStack(spacing: 10) {
                TextField("Type a word", text: $typedText)
                    .accessibilityLabel("Type a word")
                    .toddlerTextInputBehavior()
                    .onSubmit {
                        Task { await resolve(typedText) }
                    }
                    .padding(.horizontal, 14)
                    .frame(minHeight: 54)
                    .background(.white.opacity(0.88), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .foregroundStyle(KannadaTheme.ink)

                Button {
                    Task { await resolve(typedText) }
                } label: {
                    Image(systemName: isResolving ? "hourglass" : "arrow.right")
                        .font(.title3.weight(.bold))
                        .frame(width: 56, height: 54)
                }
                .buttonStyle(.borderedProminent)
                .tint(KannadaTheme.peacock)
                .disabled(typedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isResolving)
                .accessibilityLabel("Look up word")
            }
        }
        .padding(16)
        .background(KannadaTheme.marigold, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.white.opacity(0.55), lineWidth: 1)
        )
        .shadow(color: KannadaTheme.ink.opacity(0.14), radius: 18, x: 0, y: 10)
    }

    private var voicePrompt: String {
        if speechService.isListening {
            return "Listening..."
        }

        if isRunningInSimulator {
            return "Type a word, then tap mic"
        }

        return "Speak Now"
    }

    private var tinyWorldWords: [KannadaWord] {
        let preferredIDs = ["amma", "appa", "magu", "bekku", "naayi", "baalehannu", "sebu", "aane"]
        let preferred = preferredIDs.compactMap { catalog.lookup($0) }
        let fallback = catalog.words.prefix(8)
        let merged = preferred + fallback
        var seen = Set<String>()
        return merged.filter { seen.insert($0.id).inserted }.prefix(8).map { $0 }
    }

    private var selectedTinyWorldWord: KannadaWord? {
        if let selectedTinyWorldID, let selected = catalog.lookup(selectedTinyWorldID) {
            return selected
        }
        return tinyWorldWords.first
    }

    private var tinyWorldPrompt: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "hand.tap.fill")
                    .font(.title3.weight(.black))
                    .foregroundStyle(.white)
                    .frame(width: 42, height: 42)
                    .background(KannadaTheme.peacock, in: Circle())

                VStack(alignment: .leading, spacing: 3) {
                    Text("Ask without recording")
                        .font(.headline.weight(.black))
                        .foregroundStyle(KannadaTheme.ink)

                    Text("Let her ask out loud. You tap the object, and the app answers in Kannada.")
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(KannadaTheme.ink.opacity(0.68))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(tinyWorldWords) { word in
                        tinyWorldButton(word)
                    }
                }
                .padding(.vertical, 2)
            }

            Button {
                guard let word = selectedTinyWorldWord else { return }
                typedText = word.english
                resolveSelectedTinyWorldWord(word)
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.headline.weight(.black))

                    VStack(alignment: .leading, spacing: 2) {
                        Text("ಇದು ಏನು? · What's that?")
                            .font(.headline.weight(.black))
                        if let selectedTinyWorldWord {
                            Text("Answer with \(selectedTinyWorldWord.kannada) · \(selectedTinyWorldWord.transliteration)")
                                .font(.caption.weight(.semibold))
                                .opacity(0.82)
                        }
                    }

                    Spacer()
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .frame(minHeight: 62)
                .background(KannadaTheme.peacock, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Answer what is that in Kannada")
        }
        .padding(16)
        .kannadaCard(cornerRadius: 22)
    }

    private func tinyWorldButton(_ word: KannadaWord) -> some View {
        let isSelected = selectedTinyWorldWord?.id == word.id

        return Button {
            selectedTinyWorldID = word.id
        } label: {
            VStack(spacing: 7) {
                WordIllustrationView(imageName: word.imageName, category: word.category, size: 58)

                Text(word.displayEnglish)
                    .font(.caption.weight(.black))
                    .foregroundStyle(KannadaTheme.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.62)
            }
            .frame(width: 86, height: 104)
            .background(isSelected ? word.category.softColor : KannadaTheme.card, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(isSelected ? word.category.themeColor : KannadaTheme.border, lineWidth: isSelected ? 3 : 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Select \(word.displayEnglish)")
    }

    private func resolveSelectedTinyWorldWord(_ word: KannadaWord) {
        selectedTinyWorldID = word.id
        withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
            result = .curated(word, query: "What's that?")
        }
        speechOutput.speak(word.kannada, wordID: word.id)
        suggestions = []
    }

    private var isRunningInSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }

    private func handleMicrophoneTap() {
        if speechService.isListening {
            speechService.stopListening()
            return
        }

        if isRunningInSimulator {
            let typedWord = typedText.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !typedWord.isEmpty else {
                speechService.errorMessage = "Simulator voice input is limited. Type a word below, then tap the mic."
                return
            }

            speechService.errorMessage = nil
            lastResolvedTranscript = ""
            Task { await resolve(typedWord) }
            return
        }

        Task {
            lastResolvedTranscript = ""
            await speechService.startListening()
        }
    }

    private var categoryCards: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ಕಲಿಯೋಣ — Let's learn")
                .font(.headline.weight(.black))
                .foregroundStyle(KannadaTheme.ink)

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 10),
                    GridItem(.flexible(), spacing: 10),
                    GridItem(.flexible(), spacing: 10)
                ],
                spacing: 10
            ) {
                ForEach(WordCategory.allCases) { category in
                    categoryCard(category)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func categoryCard(_ category: WordCategory) -> some View {
        let sample = catalog.words.first { $0.category == category }
        let count = catalog.words.filter { $0.category == category }.count

        return Button {
            session.openLibrary(category: category)
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                WordIllustrationView(
                    imageName: sample?.imageName ?? "",
                    category: category,
                    size: 54
                )

                VStack(alignment: .leading, spacing: 3) {
                    Text(category.kannadaName)
                        .font(.headline.weight(.black))
                        .foregroundStyle(KannadaTheme.ink)
                        .lineLimit(1)
                        .minimumScaleFactor(0.62)

                    Text("\(count) words")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(KannadaTheme.ink.opacity(0.58))
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(minHeight: 126, alignment: .topLeading)
            .padding(12)
            .background(category.softColor, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(KannadaTheme.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open \(category.displayName) in Learn")
    }

    private var starterWords: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Try one")
                .font(.headline.weight(.black))
                .foregroundStyle(KannadaTheme.ink)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 96), spacing: 12)], spacing: 12) {
                ForEach(["amma", "appa", "ajji", "elephant", "mango", "dog"], id: \.self) { sample in
                    Button {
                        typedText = sample
                        Task { await resolve(sample) }
                    } label: {
                        Text(sample.capitalized)
                            .font(.callout.weight(.bold))
                            .frame(maxWidth: .infinity, minHeight: 56)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(KannadaTheme.peacock.opacity(0.16))
                    .foregroundStyle(KannadaTheme.peacockDark)
                }
            }
        }
        .padding(16)
        .kannadaCard()
    }

    private func resolve(_ input: String) async {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        isResolving = true
        defer { isResolving = false }

        if let word = catalog.lookupFromPhrase(trimmed) {
            suggestions = []
            withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                result = .curated(word, query: trimmed)
            }
            speechOutput.speak(word.kannada, wordID: word.id)
            return
        }

        suggestions = catalog.suggestions(for: trimmed)
        withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
            result = .unknown(query: trimmed)
        }
    }

    private var suggestionRow: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Try one of these")
                .font(.headline.weight(.black))
                .foregroundStyle(KannadaTheme.ink)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(suggestions) { word in
                        Button {
                            typedText = word.english
                            Task { await resolve(word.english) }
                        } label: {
                            VStack(spacing: 6) {
                                WordIllustrationView(imageName: word.imageName, category: word.category, size: 52)
                                Text(word.displayEnglish)
                                    .font(.caption.weight(.black))
                                    .foregroundStyle(KannadaTheme.ink)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                            }
                            .frame(width: 86, height: 96)
                            .kannadaCard(cornerRadius: 16)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Try \(word.displayEnglish)")
                    }
                }
            }
        }
        .padding(16)
        .kannadaCard()
    }

    private func clearResult() {
        withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
            result = nil
            suggestions = []
        }
        typedText = ""
        lastResolvedTranscript = ""
        speechService.resetTranscript()
    }

    private func isFavorite(_ result: LookupResult) -> Bool {
        guard let wordID = result.wordID else { return false }
        return favoritesStore.contains(wordID)
    }

    private func toggleFavorite(_ result: LookupResult) {
        guard let wordID = result.wordID, let word = catalog.lookup(wordID) else { return }
        favoritesStore.toggle(word)
    }
}
