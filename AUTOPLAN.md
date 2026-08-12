# Implementation Plan for /autoplan: What's This in Kannada

## Plan Summary

Build the MVP of **What's This in Kannada**, an iOS 18+ SwiftUI toddler Kannada vocabulary app. The first milestone should implement the reliable local learning loop: manual text lookup and curated library first, then speech input, then persistence and practice. Translation fallback comes after the curated path works.

## User Problem

Parents need a toddler-friendly way to turn everyday English words and family terms into Kannada learning moments. Existing translation tools are adult-oriented and do not provide large child-friendly images, family-specific vocabulary, or a playful practice loop.

## Product Direction

The app should prioritize predictable toddler learning over general translation. Curated words are the primary path. Apple Speech and Translation are useful accelerators, but the app must remain useful when those services are unavailable.

## In Scope

- iOS 18+ SwiftUI app shell.
- Home / Listen screen.
- Manual text input fallback.
- Curated word catalog for family, animals, and fruits.
- Result card with image, Kannada text, transliteration, audio button, and favorite button.
- Library screen with category filters and search.
- Favorites screen backed by local persistence.
- Flashcard practice mode.
- Speech recognition with `SFSpeechRecognizer`.
- Kannada speech output with `AVSpeechSynthesizer`.
- Apple Translation fallback after curated lookup.
- Error states for permissions, unavailable speech, unavailable translation, unknown words, missing image assets.

## Not in Scope

- Camera/object detection.
- Account system.
- Cloud sync.
- Ads.
- Open web image search in the child-facing app.
- Full grammar lessons or sentence tutoring.
- Multiplayer/social sharing.

## Architecture Plan

Use a small service-oriented SwiftUI architecture:

```text
SwiftUI Views
  -> SpeechService
  -> PhraseParser
  -> WordCatalog
  -> TranslationService
  -> SpeechOutputService
  -> FavoritesStore / local persistence
```

### New Components

- `SpeechService`: Apple Speech permission, live transcription, final transcript.
- `PhraseParser`: extracts teachable keyword from short English phrases.
- `WordCatalog`: searches curated words by English, aliases, Kannada, transliteration, category.
- `TranslationService`: English to Kannada fallback.
- `SpeechOutputService`: speaks Kannada text.
- `FavoritesStore`: persists saved words and learned state. The starter implementation can use encoded local data; SwiftData is a later swap if needed.
- `HomeView`: primary speech/text lookup flow.
- `ResultCardView`: toddler-facing result.
- `LibraryView`: searchable and filterable catalog.
- `FavoritesView`: saved words.
- `FlashcardView`: simple practice loop.

## UI Scope

This plan has UI scope. It includes Home, Library, Favorites, Word Detail, Result Card, and Practice screens.

### UI Requirements

- Large microphone button.
- Clear listening, processing, result, error, and idle states.
- Big images and large Kannada text.
- Touch targets at least 56x56 points.
- Friendly color palette without overwhelming contrast.
- No dense menus or adult translation-app feel.
- VoiceOver labels for controls.
- Reduce Motion support for animations.
- No visible developer instructions in the app UI.

## Developer-Facing Scope

This plan has developer-facing scope because it creates service boundaries, local seed data, and app architecture that future contributors will extend.

### DX Requirements

- Clear project structure.
- Seed vocabulary stored in a maintainable format.
- Services should be protocol-friendly for unit testing.
- Mock services for previews/tests.
- Error types should be explicit and user-recoverable.

## Data Model

### KannadaWord

- `id: String`
- `english: String`
- `kannada: String`
- `transliteration: String`
- `imageName: String`
- `category: WordCategory`
- `aliases: [String]`

### SavedWord

- `id`
- `wordID`
- `english`
- `kannada`
- `transliteration`
- `imageName`
- `createdAt`
- `timesPracticed`
- `learned`

## Implementation Milestones

### Milestone 1: Curated Lookup Loop

- Create SwiftUI app shell with tab navigation.
- Add `WordCatalog`.
- Add manual text input.
- Add `ResultCardView`.
- Add placeholder bundled images or category fallback art.
- Add `SpeechOutputService`.

### Milestone 2: Library and Favorites

- Add `LibraryView` with search and categories.
- Add local persistence models.
- Add save/unsave behavior.
- Add `FavoritesView`.

### Milestone 3: Speech Input

- Add `SpeechService`.
- Add permission handling.
- Add live transcription.
- Add phrase parsing.
- Route final transcript through curated lookup.

### Milestone 4: Practice

- Add flashcards for library/favorites.
- Add simple multiple-choice quiz if time allows.
- Track practice counts and learned state.

### Milestone 5: Translation Fallback and Polish

- Add Apple Translation fallback.
- Add unknown word flow.
- Add animations and sound polish.
- Improve asset quality.

## Test Plan

### Unit Tests

- `PhraseParser` extracts target words from common phrases.
- `WordCatalog` matches exact words, aliases, and case-insensitive input.
- Unknown words return a typed miss.
- Favorites save/unsave behavior.
- Quiz answer generation avoids duplicate choices.

### UI Tests

- Manual lookup shows expected Kannada result.
- Library search finds `amma`, `appa`, `elephant`, and `mango`.
- Favorite persists after navigation.
- Speech permission denied path shows text input fallback.

### Manual QA

- Test on device with Kannada voice available.
- Test on device with speech unavailable or permission denied.
- Test offline behavior for library and favorites.
- Test large text settings.
- Test Reduce Motion.

## Risks and Mitigations

| Risk | Impact | Mitigation |
|---|---|---|
| Kannada kinship terms vary by family | Wrong term erodes trust | Make family terms editable later; validate starter list with family |
| Apple Translation availability varies | Fallback may fail | Curated catalog is primary path |
| Kannada voice unavailable | Audio may not work | Text/transliteration remains usable; show soft error |
| Missing images slow build | UI feels unfinished | Use category fallback art first |
| Speech recognition mishears toddler speech | Frustrating child flow | Parent speech and text input remain primary fallback |

## Open Decisions for Review

- Whether Translation fallback belongs in MVP or should be post-MVP.
- Whether Practice mode should include quiz in MVP or just flashcards.
- Whether family terms should include both maternal/paternal variants in the first release.
- Whether seed data should live as Swift constants or JSON loaded from bundle.

## Definition of Done

- User can type `elephant` and see `ಆನೆ`, `aane`, image, and hear Kannada audio.
- User can browse family, animal, and fruit words in Library.
- User can favorite a word and find it in Favorites after app restart.
- App handles speech permission denial without dead-ending.
- Curated library works offline.
- Core services have unit tests.
- Manual QA passes on a real iOS device.

## GSTACK REVIEW REPORT

Pending `/autoplan`.
