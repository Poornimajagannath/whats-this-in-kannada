# iPhone Simulator Runbook

## Current Machine Status

```bash
xcode-select -p
# /Applications/Xcode.app/Contents/Developer
```

The app has been built and launched with Xcode 26.5 on an iPhone simulator.

```bash
xcrun simctl list devices available
```

Example tested simulator:

```bash
iPhone 17, iOS 26.5
```

## Launch the App

Open the project:

```bash
open WhatsThisInKannada.xcodeproj
```

In Xcode:

- Scheme: `WhatsThisInKannada`
- Destination: an iPhone simulator, such as `iPhone 16`
- Run: `Cmd + R`

Or from Terminal:

```bash
xcodebuild -project WhatsThisInKannada.xcodeproj -scheme WhatsThisInKannada -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath .build/DerivedData build
xcrun simctl boot "iPhone 17"
xcrun simctl install "iPhone 17" .build/DerivedData/Build/Products/Debug-iphonesimulator/WhatsThisInKannada.app
xcrun simctl launch "iPhone 17" app.whatsthiskannada
```

## Notes

- The red microphone button is intended for the real iPhone/iOS simulator app.
- On Simulator, live microphone input can be unreliable. The app shows "Type a word, then tap mic"; type a word first, then tap the red mic to resolve it.
- The macOS preview intentionally falls back to typed input for voice lookup.
- The curated catalog, flashcards, favorites, and speaker button can be tested in the preview.
- End-to-end tests for those flows run with `npx e2e run` after the simulator build above. See the README section "End-to-end tests". The suite needs a Mac with Xcode; it does not run where no iOS simulator is installed.
