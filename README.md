# TennisScoreWatch

Starter watchOS (SwiftUI) tennis score tracker.

## How to run
1. In Xcode, create a **watchOS App** (watch-only, SwiftUI, watchOS 10+).
2. Replace the generated `ContentView.swift` and app entry file with the files in:
   - `TennisScoreWatch/TennisScoreWatchApp/ContentView.swift`
   - `TennisScoreWatch/TennisScoreWatchApp/TennisScoreWatchApp.swift`
3. Add `ScoreModel.swift` to the target.
4. Build and run on a simulator or device.

## Features
- Two-player tennis scoring (0, 15, 30, 40, AD)
- Games, sets, and match win (best of 3)
- Undo and reset
- Local persistence

## Notes
- Logic is simplified to standard tennis rules.
- Persistence is local to the watch using `UserDefaults`.
