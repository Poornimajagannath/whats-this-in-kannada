import Foundation

enum PracticeEngine {
    static func flashcardIndex(current: Int, count: Int, delta: Int) -> Int {
        guard count > 0 else { return 0 }
        let next = (current + delta) % count
        return next >= 0 ? next : next + count
    }

    static func makeQuizRound(
        prompt: KannadaWord,
        from words: [KannadaWord],
        choiceCount: Int = 4
    ) -> (prompt: KannadaWord, choices: [KannadaWord]) {
        let needed = max(0, choiceCount - 1)
        let distractors = words
            .filter { $0.id != prompt.id }
            .shuffled()
            .prefix(needed)
        return (prompt, ([prompt] + Array(distractors)).shuffled())
    }

    static func makeQuizRound(
        from words: [KannadaWord],
        choiceCount: Int = 4
    ) -> (prompt: KannadaWord, choices: [KannadaWord])? {
        guard let prompt = words.randomElement() else { return nil }
        return makeQuizRound(prompt: prompt, from: words, choiceCount: choiceCount)
    }

    static func progress(completed: Int, total: Int) -> Double {
        guard total > 0 else { return 0 }
        return min(1, max(0, Double(completed) / Double(total)))
    }

    static func isCorrect(choiceID: String, promptID: String) -> Bool {
        choiceID == promptID
    }
}
