# PaddleTrackerWatch

Starter watchOS (SwiftUI) tennis score tracker.

## How to run
1. Open `PaddleTrackerWatch/PaddleTrackerWatch.xcodeproj` in Xcode.
2. Select the watch target and build/run on a simulator or device.

## Open in Xcode (GitHub)
1. In GitHub, click the green **Code** button.
2. Choose **Open with Xcode**.
3. Xcode will clone and open the project.

## Features
- Two-player tennis scoring (0, 15, 30, 40, AD)
- Games, sets, and match win (best of 3)
- Undo and reset
- Local persistence

## Notes
- Logic is simplified to standard tennis rules.
- Persistence is local to the watch using `UserDefaults`.
