import SwiftUI

@main
struct BeerScannerApp: App {
    @StateObject private var scanHistory = ScanHistoryStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(scanHistory)
        }
    }
}
