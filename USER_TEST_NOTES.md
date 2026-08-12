# User Test Notes

## 2026-06-12 Toddler Test

### What Worked

- Flashcards were the strongest feature.
- Child stayed engaged long enough to learn through `bear`.
- The family/animal/fruit vocabulary set is directionally right for early use.

### Problems Observed

- App crashed during demo use.
- Red voice button did not appear to work reliably.
- Placeholder emoji art looked cheap and produced yellow emoji-style people.
- Visual assets need to feel like toddler illustrations, not system emoji.

### Changes Made After Test

- Tried local SwiftUI toddler-style illustrations.
- Added non-yellow family portraits with warmer brown skin tones.
- Hardened speech startup so unavailable microphone/speech paths show text fallback instead of crashing.
- Added permission strings to the macOS preview bundle.

## 2026-06-12 Image Revert

The custom SwiftUI illustrations were not recognizable enough, especially animals and birds. Reverted the visual layer to the earlier emoji placeholders so flashcards remain decipherable while a better real asset set is sourced.

### Product Signal

Keep investing in flashcards before adding more complex practice games. The simple image -> Kannada reveal loop worked in the room.
