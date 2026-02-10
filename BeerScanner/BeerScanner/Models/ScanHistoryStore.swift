import Foundation
import SwiftUI

class ScanHistoryStore: ObservableObject {
    @Published var results: [ScanResult] = []

    private let storageKey = "beer_scan_history"

    init() {
        loadHistory()
    }

    func addResult(_ result: ScanResult) {
        results.insert(result, at: 0)
        saveHistory()
    }

    func removeResult(at offsets: IndexSet) {
        results.remove(atOffsets: offsets)
        saveHistory()
    }

    func clearHistory() {
        results.removeAll()
        saveHistory()
    }

    private func saveHistory() {
        if let data = try? JSONEncoder().encode(results) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([ScanResult].self, from: data) {
            results = decoded
        }
    }
}
