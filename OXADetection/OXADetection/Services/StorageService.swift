import UIKit

// MARK: - Storage Service

class StorageService {
    static let shared = StorageService()

    private let fileManager = FileManager.default

    private var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private var scansDirectory: URL {
        documentsDirectory.appendingPathComponent("Scans", isDirectory: true)
    }

    private init() {
        createDirectoryIfNeeded(scansDirectory)
    }

    // MARK: - Directory Management

    private func createDirectoryIfNeeded(_ url: URL) {
        if !fileManager.fileExists(atPath: url.path) {
            try? fileManager.createDirectory(at: url, withIntermediateDirectories: true)
        }
    }

    func sessionDirectory(for sessionId: UUID) -> URL {
        let dir = scansDirectory.appendingPathComponent(sessionId.uuidString, isDirectory: true)
        createDirectoryIfNeeded(dir)
        return dir
    }

    // MARK: - Image Storage

    func saveImage(_ image: UIImage, sessionId: UUID, name: String) throws -> String {
        let dir = sessionDirectory(for: sessionId)
        let fileName = "\(name).jpg"
        let filePath = dir.appendingPathComponent(fileName)

        guard let data = image.jpegData(compressionQuality: 0.9) else {
            throw StorageError.imageConversionFailed
        }

        try data.write(to: filePath)
        return filePath.path
    }

    func loadImage(at path: String) -> UIImage? {
        UIImage(contentsOfFile: path)
    }

    // MARK: - Session Storage

    func saveSession(_ session: ScanSession) throws {
        let dir = sessionDirectory(for: session.id)
        let filePath = dir.appendingPathComponent("session.json")

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        let data = try encoder.encode(session)
        try data.write(to: filePath)
    }

    func loadSession(id: UUID) throws -> ScanSession {
        let dir = sessionDirectory(for: id)
        let filePath = dir.appendingPathComponent("session.json")

        let data = try Data(contentsOf: filePath)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(ScanSession.self, from: data)
    }

    func listSessions() -> [UUID] {
        guard let contents = try? fileManager.contentsOfDirectory(
            at: scansDirectory,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: .skipsHiddenFiles
        ) else { return [] }

        return contents.compactMap { url in
            UUID(uuidString: url.lastPathComponent)
        }
    }

    // MARK: - Report Export

    func exportReportAsJSON(_ report: OSHReport, sessionId: UUID) throws -> URL {
        let dir = sessionDirectory(for: sessionId)
        let filePath = dir.appendingPathComponent("report.json")

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        let data = try encoder.encode(report)
        try data.write(to: filePath)
        return filePath
    }

    func exportReportAsPDF(_ report: OSHReport, sessionId: UUID) throws -> URL {
        let dir = sessionDirectory(for: sessionId)
        let filePath = dir.appendingPathComponent("report.pdf")

        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 595, height: 842))

        let data = pdfRenderer.pdfData { context in
            context.beginPage()
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24)
            ]
            let title = "OXA Detektionsrapport"
            title.draw(at: CGPoint(x: 40, y: 40), withAttributes: attrs)

            let bodyAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12)
            ]

            var yOffset: CGFloat = 80

            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            dateFormatter.timeStyle = .medium
            dateFormatter.locale = Locale(identifier: "sv_SE")

            let info = """
            Datum: \(dateFormatter.string(from: report.timestamp))
            Plats: \(report.location.map { "\($0.latitude), \($0.longitude)" } ?? "Ej tillgänglig")
            Scan-läge: \(report.scanMode.rawValue)
            Totalt antal bilder: \(report.totalImages)
            Antal detektioner: \(report.detections.count)
            AI-modellversion: \(report.aiModelVersion)
            """
            info.draw(at: CGPoint(x: 40, y: yOffset), withAttributes: bodyAttrs)
            yOffset += 120

            if !report.detections.isEmpty {
                let detHeader = "Detektioner:"
                detHeader.draw(at: CGPoint(x: 40, y: yOffset), withAttributes: [
                    .font: UIFont.boldSystemFont(ofSize: 16)
                ])
                yOffset += 30

                for (index, detection) in report.detections.enumerated() {
                    if yOffset > 750 {
                        context.beginPage()
                        yOffset = 40
                    }

                    let detText = """
                    \(index + 1). Kvadrant: \(detection.quadrant)
                       Typ: \(detection.type)
                       Konfidens: \(detection.confidence)
                       Beskrivning: \(detection.description)
                    """
                    detText.draw(at: CGPoint(x: 40, y: yOffset), withAttributes: bodyAttrs)
                    yOffset += 70
                }
            }
        }

        try data.write(to: filePath)
        return filePath
    }

    // MARK: - Cleanup

    func deleteSession(id: UUID) throws {
        let dir = sessionDirectory(for: id)
        try fileManager.removeItem(at: dir)
    }
}

// MARK: - Storage Errors

enum StorageError: LocalizedError {
    case imageConversionFailed
    case sessionNotFound
    case exportFailed(String)

    var errorDescription: String? {
        switch self {
        case .imageConversionFailed:
            return "Kunde inte konvertera bild"
        case .sessionNotFound:
            return "Scan-session ej hittad"
        case .exportFailed(let msg):
            return "Export misslyckades: \(msg)"
        }
    }
}
