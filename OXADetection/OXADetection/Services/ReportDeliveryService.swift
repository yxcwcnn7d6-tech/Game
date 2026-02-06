import Foundation
import MessageUI
import UIKit

// MARK: - Report Delivery Service

class ReportDeliveryService: ObservableObject {
    @Published var isSending = false
    @Published var lastResult: DeliveryResult?

    // MARK: - Delivery Result

    enum DeliveryResult {
        case success(String)
        case failure(String)

        var message: String {
            switch self {
            case .success(let msg): return msg
            case .failure(let msg): return msg
            }
        }

        var isSuccess: Bool {
            if case .success = self { return true }
            return false
        }
    }

    // MARK: - Send via Email

    /// Prepares email data with report attachment.
    /// Returns the subject, body, and attachment data for use with MFMailComposeViewController.
    func prepareEmail(
        report: OSHReport,
        sessionId: UUID,
        recipientEmail: String,
        format: ReportFormat
    ) throws -> EmailData {
        let subject = "OXA Detektionsrapport - \(formattedDate(report.timestamp))"

        let body = """
        OXA Detektionsrapport
        =====================
        Datum: \(formattedDate(report.timestamp))
        Plats: \(report.location.map { "\($0.latitude), \($0.longitude)" } ?? "Ej tillgänglig")
        Skanningsläge: \(report.scanMode.rawValue)
        Antal bilder: \(report.totalImages)
        Antal detektioner: \(report.detections.count)

        \(report.detections.isEmpty ? "Inga misstänkta objekt detekterade." : detectionsSummary(report.detections))

        ---
        Genererad av OXA Detektion v\(report.aiModelVersion)
        Se bifogad fil för fullständig rapport.
        """

        var attachmentData: Data
        var attachmentMimeType: String
        var attachmentFileName: String

        switch format {
        case .osh, .custom:
            let url = try StorageService.shared.exportReportAsJSON(report, sessionId: sessionId)
            attachmentData = try Data(contentsOf: url)
            attachmentMimeType = "application/json"
            attachmentFileName = "oxa-rapport-\(sessionId.uuidString.prefix(8)).json"
        case .simple:
            let url = try StorageService.shared.exportReportAsPDF(report, sessionId: sessionId)
            attachmentData = try Data(contentsOf: url)
            attachmentMimeType = "application/pdf"
            attachmentFileName = "oxa-rapport-\(sessionId.uuidString.prefix(8)).pdf"
        }

        return EmailData(
            recipient: recipientEmail,
            subject: subject,
            body: body,
            attachmentData: attachmentData,
            attachmentMimeType: attachmentMimeType,
            attachmentFileName: attachmentFileName
        )
    }

    // MARK: - Send via API

    /// Sends report JSON to a configured API endpoint.
    func sendToAPI(
        report: OSHReport,
        endpoint: String,
        apiKey: String
    ) async -> DeliveryResult {
        await MainActor.run { isSending = true }
        defer { Task { @MainActor in isSending = false } }

        guard let url = URL(string: endpoint) else {
            let result = DeliveryResult.failure("Ogiltig API-URL: \(endpoint)")
            await MainActor.run { lastResult = result }
            return result
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if !apiKey.isEmpty {
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        }

        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = [.sortedKeys]
            request.httpBody = try encoder.encode(report)

            let (_, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                let result = DeliveryResult.failure("Ogiltigt svar från server")
                await MainActor.run { lastResult = result }
                return result
            }

            if (200...299).contains(httpResponse.statusCode) {
                let result = DeliveryResult.success("Rapport skickad till \(endpoint)")
                await MainActor.run { lastResult = result }
                return result
            } else {
                let result = DeliveryResult.failure("Server svarade med status \(httpResponse.statusCode)")
                await MainActor.run { lastResult = result }
                return result
            }
        } catch {
            let result = DeliveryResult.failure("Kunde inte skicka rapport: \(error.localizedDescription)")
            await MainActor.run { lastResult = result }
            return result
        }
    }

    // MARK: - Helpers

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .medium
        formatter.locale = Locale(identifier: "sv_SE")
        return formatter.string(from: date)
    }

    private func detectionsSummary(_ detections: [OSHDetection]) -> String {
        detections.enumerated().map { index, det in
            """
            Detektion \(index + 1):
              Typ: \(det.type)
              Konfidens: \(det.confidence)
              Kvadrant: \(det.quadrant)
              Beskrivning: \(det.description)
            """
        }.joined(separator: "\n")
    }
}

// MARK: - Email Data

struct EmailData {
    let recipient: String
    let subject: String
    let body: String
    let attachmentData: Data
    let attachmentMimeType: String
    let attachmentFileName: String
}

// MARK: - Mail Compose View (UIKit wrapper)

struct MailComposeView: UIViewControllerRepresentable {
    let emailData: EmailData
    let onDismiss: (Bool) -> Void

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = context.coordinator
        composer.setToRecipients([emailData.recipient])
        composer.setSubject(emailData.subject)
        composer.setMessageBody(emailData.body, isHTML: false)
        composer.addAttachmentData(
            emailData.attachmentData,
            mimeType: emailData.attachmentMimeType,
            fileName: emailData.attachmentFileName
        )
        return composer
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onDismiss: onDismiss)
    }

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let onDismiss: (Bool) -> Void

        init(onDismiss: @escaping (Bool) -> Void) {
            self.onDismiss = onDismiss
        }

        func mailComposeController(
            _ controller: MFMailComposeViewController,
            didFinishWith result: MFMailComposeResult,
            error: Error?
        ) {
            let success = result == .sent
            controller.dismiss(animated: true) {
                self.onDismiss(success)
            }
        }
    }
}
