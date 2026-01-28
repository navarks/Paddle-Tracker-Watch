import SwiftUI

@main
struct PaddleTrackerWatch_Watch_AppApp: App {
    @StateObject private var model = ScoreModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(model)
        }
    }
}
