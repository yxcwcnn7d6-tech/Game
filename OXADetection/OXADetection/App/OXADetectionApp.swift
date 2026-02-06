import SwiftUI

@main
struct OXADetectionApp: App {
    @StateObject private var settings = AppSettings.load()

    var body: some Scene {
        WindowGroup {
            StartScreen()
                .environmentObject(settings)
        }
    }
}
