# What's This in Kannada

Toddler-friendly iOS app concept for helping a child learn Kannada words from everyday English speech.

## Project Artifacts

- [WhatsThisInKannada.xcodeproj](WhatsThisInKannada.xcodeproj) - SwiftUI iOS app project.
- [WhatsThisInKannada/](WhatsThisInKannada/) - App source, resources, and assets.
- [WhatsThisInKannadaTests/](WhatsThisInKannadaTests/) - Starter unit tests for parsing and catalog lookup.
- [PRD.md](PRD.md) - Product requirements and MVP definition.
- [ARCHITECTURE.md](ARCHITECTURE.md) - App architecture and diagrams.
- [AUTOPLAN.md](AUTOPLAN.md) - Review-ready implementation plan for gstack `/autoplan`.
- [word-seed.json](word-seed.json) - Starter vocabulary for family members, animals, and fruits.

## MVP Summary

Parent or child says an English word or short phrase like "fan", "elephant", or "this is amma". The app extracts the likely object/person word, shows the Kannada word with Roman transliteration, displays a toddler-friendly image, and plays Kannada pronunciation.

Target platform: iOS 18+, SwiftUI, Apple-native services where practical.

## Run It

Open `WhatsThisInKannada.xcodeproj` in Xcode and run the `WhatsThisInKannada` scheme on an iPhone simulator or device.

```bash
xcodebuild test -project WhatsThisInKannada.xcodeproj -scheme WhatsThisInKannada \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

The project has been tested with Xcode 26.5+ on an iPhone 17 simulator. Simulator voice input uses the typed-word fallback; live microphone recognition still needs physical iPhone testing.

## Current Implementation

- Home speech/text lookup flow, including Kannada script and "Try another".
- Local curated catalog with 59 words and nearby suggestions for unknown words.
- Kannada-first Home, Learn, Play, and Parent tabs.
- Library search, category filters, and a hold-to-open Parent favorites gate.
- Saved words with local encoded persistence.
- Flashcards, picture-to-Kannada quiz, and object-walk practice with real progress.
- Kannada audio via `AVSpeechSynthesizer`.
- English speech recognition via `SFSpeechRecognizer`.
- Native folk-art style toddler illustrations for common family, animal, and fruit cards.
