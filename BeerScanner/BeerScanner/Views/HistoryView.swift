import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var scanHistory: ScanHistoryStore

    var body: some View {
        NavigationStack {
            Group {
                if scanHistory.results.isEmpty {
                    EmptyHistoryView()
                } else {
                    List {
                        ForEach(scanHistory.results) { result in
                            NavigationLink(destination: BeerDetailView(beer: result.beer)) {
                                HistoryRow(result: result)
                            }
                        }
                        .onDelete { offsets in
                            scanHistory.removeResult(at: offsets)
                        }
                    }
                }
            }
            .navigationTitle("Scan History")
            .toolbar {
                if !scanHistory.results.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Clear All") {
                            scanHistory.clearHistory()
                        }
                        .foregroundColor(.red)
                    }
                }
            }
        }
    }
}

struct HistoryRow: View {
    let result: ScanResult

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(LinearGradient.beerGradient)
                    .frame(width: 50, height: 50)
                Text(String(result.beer.brand.prefix(2)).uppercased())
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(result.beer.name)
                    .font(.headline)
                HStack(spacing: 8) {
                    Text(result.beer.style)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.0f%% match", result.confidence * 100))
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.beerGold)
                }
                Text(result.scannedAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(String(format: "%.1f%%", result.beer.abv))
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.beerAmber)
        }
        .padding(.vertical, 4)
    }
}

struct EmptyHistoryView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 60))
                .foregroundColor(.beerGold.opacity(0.4))

            Text("No Scans Yet")
                .font(.title2.bold())
                .foregroundColor(.primary)

            Text("Scan a beer can to see your\nhistory appear here")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}
