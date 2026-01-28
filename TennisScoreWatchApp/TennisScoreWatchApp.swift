import SwiftUI

@main
struct TennisScoreWatchApp: App {
    @StateObject private var model = ScoreModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(model)
        }
    }
}
