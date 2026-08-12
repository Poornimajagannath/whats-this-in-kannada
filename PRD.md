# PRD: What's This in Kannada

## 1. Product Summary

**What's This in Kannada** is a toddler-friendly iOS app that helps a child learn Kannada words for familiar people, animals, fruits, and everyday objects. A parent or child can speak an English word or phrase, and the app responds with a large cute image, Kannada text, Roman transliteration, and spoken Kannada pronunciation.

The first version intentionally avoids camera-based object detection. The core learning loop is simpler, more reliable, more private, and easier to build: **speak English -> show Kannada -> hear Kannada -> save/practice later**.

## 2. Target Users

### Primary User

A parent or caregiver who wants to casually teach Kannada vocabulary to a toddler during everyday moments.

### Secondary User

A toddler or young child who taps large buttons, recognizes images, hears sounds, and repeats words.

## 3. Problem

Parents who speak Kannada or want to preserve Kannada at home often need an easy way to turn everyday objects and family words into quick learning moments. Existing translation apps are adult-oriented, text-heavy, and not designed for toddlers. Flashcard apps often lack speech input, Kannada audio, or culturally familiar family terms like `amma`, `appa`, `ajji`, `taatha`, `maava`, and `atte`.

## 4. Goals

- Let a parent speak an English word or short phrase and get the Kannada word quickly.
- Make the result delightful and legible for a toddler: big image, large Kannada text, simple audio.
- Support common family words, animals, and fruits from a local curated word list.
- Work offline-first for the curated word library and favorites.
- Provide a foundation for practice modes like flashcards, matching, and simple quizzes.

## 5. Non-Goals

- No camera or object detection in MVP.
- No social accounts, sharing, messaging, or cloud sync in MVP.
- No open web image search in the toddler-facing flow.
- No full sentence grammar tutoring in MVP.
- No user-generated public content.
- No ads.

## 6. MVP User Journey

1. User opens the app.
2. Home screen shows a large friendly microphone button and optional text input.
3. User says a word or phrase, such as "elephant", "this is a mango", or "where is appa?"
4. App transcribes the speech to English text.
5. App extracts the most likely teachable word.
6. App checks the curated word catalog first.
7. If a match exists, app shows:
   - Large toddler-friendly image.
   - Kannada word in large font.
   - Roman transliteration.
   - Speaker button for Kannada pronunciation.
   - Favorite button.
8. If no curated match exists, app attempts translation using Apple Translation framework.
9. User can save the result to Favorites.
10. User can browse Library by category and practice saved/common words.

## 7. Core Features

### 7.1 Home / Listen

**Requirements**

- Large microphone button with clear listening, processing, and idle states.
- Live transcription preview while listening.
- Automatic result after speech ends.
- Manual fallback text field.
- Result card with image, Kannada word, transliteration, and audio button.
- Friendly error handling for permission denial, no speech detected, and unknown words.

**Success Criteria**

- Parent can go from opening app to hearing a Kannada word in under 10 seconds.
- Toddler can tap the audio button without precise motor control.
- Text and controls are readable from arm's length.

### 7.2 Word Library

**Requirements**

- Searchable list or grid of curated toddler words.
- Categories:
  - Family
  - Animals
  - Fruits
  - Later: home objects, toys, vehicles, body parts, food.
- Each word displays English, Kannada, transliteration, and image.
- Tapping a word opens detail view and can play pronunciation.

**Success Criteria**

- Parent can find `amma`, `appa`, `ajji`, `taatha`, animals, and fruits without speech input.
- Library works fully offline.

### 7.3 Favorites / My Words

**Requirements**

- User can save and unsave words.
- Favorites persist locally.
- Favorites can be used in practice mode.

**Success Criteria**

- A saved word appears in Favorites immediately after tapping save.
- Favorites persist across app restarts.

### 7.4 Practice Mode

**MVP Scope**

- Flashcards: image front, Kannada/audio back.
- Simple multiple-choice quiz: show image, choose Kannada word.

**Post-MVP**

- Matching game.
- Streaks.
- Confetti or celebratory animation for correct answers.
- Parent-controlled difficulty.

## 8. Vocabulary Scope

MVP starts with roughly 60 curated words:

- Family members and kinship terms.
- Animals.
- Fruits.

The curated list should be the source of truth for known words. Translation is fallback, not the primary path, because curated Kannada gives better toddler-safe wording, transliteration, images, and audio behavior.

## 9. Technical Requirements

### Platform

- iOS 18+
- SwiftUI
- Swift concurrency with async/await

### Apple Frameworks

- `Speech` framework via `SFSpeechRecognizer` for English speech recognition.
- `Translation` framework for English to Kannada fallback translation where available.
- `AVFoundation` via `AVSpeechSynthesizer` for Kannada speech output.
- Local persistence for saved words, learned status, and practice progress. The starter app uses a small encoded `FavoritesStore`; SwiftData remains a natural upgrade once the core loop is stable.

### Offline Behavior

- Curated library works offline.
- Favorites work offline.
- Bundled images work offline.
- Speech and translation may depend on device capability, downloaded language assets, OS support, and system permissions. The app must gracefully fall back to text input and curated library search.

## 10. Design Requirements

- Kid-friendly, bright, and calm.
- Large tap targets, minimum 56x56 points.
- No dense menus.
- No ads, popups, or external links in the child-facing flow.
- Use big imagery as the main visual anchor.
- Keep primary actions obvious: listen, play sound, save.
- Support Dynamic Type where practical, but preserve toddler-card layout.
- Avoid relying on color alone for quiz correctness.

## 11. Accessibility

- VoiceOver labels for all controls.
- High-contrast text over backgrounds.
- Large tap targets.
- Captions/transliteration always visible alongside Kannada text.
- Reduce Motion support: replace large celebratory animation with subtle success state.

## 12. Privacy and Safety

- No account required.
- No analytics in MVP unless explicitly added later with parental consent.
- No user speech stored by default.
- No child personal information collected.
- No open web search in the app.
- All content is bundled or curated.

## 13. Data Model

### KannadaWord

- `id`: stable slug.
- `english`: English label.
- `kannada`: Kannada script.
- `transliteration`: Roman transliteration.
- `imageName`: bundled asset name.
- `category`: family, animals, fruits, etc.
- `aliases`: optional English phrase aliases.

### SavedWord

- `wordID`: references curated word when applicable.
- `english`: original English text.
- `kannada`: Kannada result.
- `transliteration`: optional.
- `imageName`: optional.
- `createdAt`: date.
- `timesPracticed`: integer.
- `learned`: boolean.

## 14. Success Metrics

### MVP Product Metrics

- Time from app launch to first spoken Kannada word: target under 10 seconds.
- Successful curated match rate for toddler library terms: target above 90%.
- Parent can save a word in one tap.

### Quality Metrics

- Speech permission denial has a clear fallback path.
- No app crash when speech, translation, or audio services are unavailable.
- Library and favorites work offline.

## 15. Open Questions

- Which dialect/family conventions should the kinship terms follow?
- Should the app default to Kannada words commonly used in Bengaluru/Mysuru households, or allow family-specific overrides?
- Should family words use photos/custom avatars later, or only illustrations?
- Should transliteration be phonetic for English speakers or closer to academic transliteration?

## 16. Release Plan

### Milestone 1: Core Loop

- SwiftUI shell with Home, Library, Favorites tabs.
- Curated word catalog.
- Manual text input lookup.
- Result card.
- Kannada speech output.

### Milestone 2: Speech Input

- Speech permission flow.
- English transcription.
- Phrase cleanup and word extraction.
- Curated lookup from recognized speech.

### Milestone 3: Favorites and Practice

- Local favorites persistence.
- Save/unsave words.
- Flashcards.
- Simple multiple-choice quiz.

### Milestone 4: Translation Fallback and Polish

- Apple Translation fallback.
- Missing word state.
- Better animations and sound effects.
- Asset pass for toddler-friendly images.
