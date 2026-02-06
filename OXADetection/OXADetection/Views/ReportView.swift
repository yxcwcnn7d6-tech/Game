import SwiftUI

// MARK: - Report View

struct ReportView: View {
    let report: OSHReport
    let sessionId: UUID
    @EnvironmentObject var settings: AppSettings
    @Environment(\.dismiss) private var dismiss
    @StateObject private var deliveryService = ReportDeliveryService()
    @State private var showingShareSheet = false
    @State private var showingMailCompose = false
    @State private var emailData: EmailData?
    @State private var exportURL: URL?
    @State private var exportError: String?
    @State private var deliveryMessage: String?
    @State private var deliveryIsSuccess = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    headerSection

                    // Summary
                    summarySection

                    // Detections
                    if !report.detections.isEmpty {
                        detectionsSection
                    } else {
                        noDetectionsView
                    }

                    // Map placeholder
                    if report.location != nil {
                        locationSection
                    }

                    // Send actions
                    sendSection
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Rapport")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Stäng") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            exportJSON()
                        } label: {
                            Label("Exportera JSON", systemImage: "doc.text")
                        }
                        Button {
                            exportPDF()
                        } label: {
                            Label("Exportera PDF", systemImage: "doc.richtext")
                        }

                        Divider()

                        if !settings.reportRecipientEmail.isEmpty {
                            Button {
                                sendViaEmail()
                            } label: {
                                Label("Skicka via e-post", systemImage: "envelope")
                            }
                        }

                        if !settings.reportAPIEndpoint.isEmpty {
                            Button {
                                Task { await sendToAPI() }
                            } label: {
                                Label("Skicka till API", systemImage: "arrow.up.circle")
                            }
                        }
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                if let url = exportURL {
                    ShareSheet(items: [url])
                }
            }
            .sheet(isPresented: $showingMailCompose) {
                if let emailData = emailData {
                    MailComposeView(emailData: emailData) { success in
                        showingMailCompose = false
                        deliveryMessage = success ? "E-post skickad" : "E-post avbruten"
                        deliveryIsSuccess = success
                    }
                }
            }
            .alert("Exportfel", isPresented: .init(
                get: { exportError != nil },
                set: { if !$0 { exportError = nil } }
            )) {
                Button("OK") { exportError = nil }
            } message: {
                Text(exportError ?? "")
            }
            .alert(
                deliveryIsSuccess ? "Skickat" : "Fel",
                isPresented: .init(
                    get: { deliveryMessage != nil },
                    set: { if !$0 { deliveryMessage = nil } }
                )
            ) {
                Button("OK") { deliveryMessage = nil }
            } message: {
                Text(deliveryMessage ?? "")
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "viewfinder.trianglebadge.exclamationmark")
                    .font(.title)
                    .foregroundStyle(.orange)
                Text("OXA Detektionsrapport")
                    .font(.title2.bold())
            }

            let dateFormatter: DateFormatter = {
                let f = DateFormatter()
                f.dateStyle = .long
                f.timeStyle = .medium
                f.locale = Locale(identifier: "sv_SE")
                return f
            }()

            Text(dateFormatter.string(from: report.timestamp))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Summary

    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Sammanfattning")
                .font(.headline)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                SummaryCard(
                    icon: "photo.stack",
                    title: "Bilder",
                    value: "\(report.totalImages)"
                )
                SummaryCard(
                    icon: "exclamationmark.triangle",
                    title: "Detektioner",
                    value: "\(report.detections.count)",
                    color: report.detections.isEmpty ? .green : .red
                )
                SummaryCard(
                    icon: "viewfinder",
                    title: "Skanningsläge",
                    value: report.scanMode.rawValue
                )
                SummaryCard(
                    icon: "cpu",
                    title: "AI-version",
                    value: report.aiModelVersion
                )
            }
        }
        .padding()
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Detections

    private var detectionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Detekterade objekt")
                .font(.headline)

            ForEach(report.detections) { detection in
                DetectionCard(detection: detection)
            }
        }
        .padding()
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var noDetectionsView: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 48))
                .foregroundStyle(.green)
            Text("Inga misstänkta objekt detekterade")
                .font(.headline)
            Text("AI-analysen fann inga objekt som matchar sökkriterier")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(30)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Location

    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Plats")
                .font(.headline)

            if let loc = report.location {
                HStack {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundStyle(.red)
                    Text("\(loc.latitude, specifier: "%.6f"), \(loc.longitude, specifier: "%.6f")")
                        .font(.system(.body, design: .monospaced))
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Send Section

    private var sendSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            let hasEmail = !settings.reportRecipientEmail.isEmpty
            let hasAPI = !settings.reportAPIEndpoint.isEmpty

            if hasEmail || hasAPI {
                Text("Skicka rapport")
                    .font(.headline)

                if hasEmail {
                    Button {
                        sendViaEmail()
                    } label: {
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundStyle(.blue)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Skicka via e-post")
                                    .font(.subheadline.bold())
                                    .foregroundStyle(.primary)
                                Text(settings.reportRecipientEmail)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }

                if hasAPI {
                    Button {
                        Task { await sendToAPI() }
                    } label: {
                        HStack {
                            Image(systemName: "arrow.up.circle.fill")
                                .foregroundStyle(.green)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Skicka till API")
                                    .font(.subheadline.bold())
                                    .foregroundStyle(.primary)
                                Text(settings.reportAPIEndpoint)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                            }
                            Spacer()
                            if deliveryService.isSending {
                                ProgressView()
                            } else {
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .disabled(deliveryService.isSending)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Send Actions

    private func sendViaEmail() {
        do {
            emailData = try deliveryService.prepareEmail(
                report: report,
                sessionId: sessionId,
                recipientEmail: settings.reportRecipientEmail,
                format: settings.reportFormat
            )
            showingMailCompose = true
        } catch {
            exportError = error.localizedDescription
        }
    }

    private func sendToAPI() async {
        let result = await deliveryService.sendToAPI(
            report: report,
            endpoint: settings.reportAPIEndpoint,
            apiKey: settings.reportAPIKey
        )
        deliveryMessage = result.message
        deliveryIsSuccess = result.isSuccess
    }

    // MARK: - Export

    private func exportJSON() {
        do {
            let url = try StorageService.shared.exportReportAsJSON(report, sessionId: sessionId)
            exportURL = url
            showingShareSheet = true
        } catch {
            exportError = error.localizedDescription
        }
    }

    private func exportPDF() {
        do {
            let url = try StorageService.shared.exportReportAsPDF(report, sessionId: sessionId)
            exportURL = url
            showingShareSheet = true
        } catch {
            exportError = error.localizedDescription
        }
    }
}

// MARK: - Summary Card

struct SummaryCard: View {
    let icon: String
    let title: String
    let value: String
    var color: Color = .blue

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            Text(value)
                .font(.title3.bold())
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Detection Card

struct DetectionCard: View {
    let detection: OSHDetection

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(confidenceColor)
                Text(detection.type)
                    .font(.subheadline.bold())
                Spacer()
                Text("Konfidens: \(detection.confidence)")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(confidenceColor.opacity(0.15))
                    .foregroundStyle(confidenceColor)
                    .clipShape(Capsule())
            }

            Text(detection.description)
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack {
                Label("Kvadrant: \(detection.quadrant)", systemImage: "square.grid.2x2")
                    .font(.caption2)
                Spacer()
                Label(
                    "(\(detection.coordinates.x), \(detection.coordinates.y))",
                    systemImage: "mappin"
                )
                .font(.caption2)
            }
            .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var confidenceColor: Color {
        switch detection.confidence {
        case "hög": return .red
        case "medel": return .orange
        default: return .yellow
        }
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
