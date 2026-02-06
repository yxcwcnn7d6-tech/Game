import SwiftUI

// MARK: - History View

struct HistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var sessionIds: [UUID] = []
    @State private var sessions: [UUID: ScanSession] = [:]

    var body: some View {
        NavigationStack {
            Group {
                if sessionIds.isEmpty {
                    emptyState
                } else {
                    sessionList
                }
            }
            .navigationTitle("Historik")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Klar") { dismiss() }
                }
            }
            .onAppear {
                loadSessions()
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 48))
                .foregroundStyle(.gray)
            Text("Ingen historik")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text("Genomförda skanningar visas här")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }

    private var sessionList: some View {
        List {
            ForEach(sessionIds, id: \.self) { id in
                if let session = sessions[id] {
                    SessionRow(session: session)
                }
            }
            .onDelete(perform: deleteSessions)
        }
    }

    private func loadSessions() {
        sessionIds = StorageService.shared.listSessions()
        for id in sessionIds {
            if let session = try? StorageService.shared.loadSession(id: id) {
                sessions[id] = session
            }
        }
    }

    private func deleteSessions(at offsets: IndexSet) {
        for index in offsets {
            let id = sessionIds[index]
            try? StorageService.shared.deleteSession(id: id)
            sessions.removeValue(forKey: id)
        }
        sessionIds.remove(atOffsets: offsets)
    }
}

// MARK: - Session Row

struct SessionRow: View {
    let session: ScanSession

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "viewfinder")
                .font(.title3)
                .foregroundStyle(.orange)
                .frame(width: 40, height: 40)
                .background(Color.orange.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(formattedDate)
                    .font(.subheadline.bold())

                HStack(spacing: 8) {
                    Label("\(session.totalImages) bilder", systemImage: "photo")
                    Label("\(session.detections.count) detektioner", systemImage: "exclamationmark.triangle")
                }
                .font(.caption2)
                .foregroundStyle(.secondary)

                Text(session.scanMode.rawValue)
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.orange.opacity(0.1))
                    .foregroundStyle(.orange)
                    .clipShape(Capsule())
            }

            Spacer()

            if session.scanPhase == .completed {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }
        }
        .padding(.vertical, 4)
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "sv_SE")
        return formatter.string(from: session.startTime)
    }
}
