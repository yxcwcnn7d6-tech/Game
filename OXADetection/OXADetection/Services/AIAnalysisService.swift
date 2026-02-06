import Vision
import UIKit
import CoreML

// MARK: - AI Analysis Service

class AIAnalysisService: ObservableObject {
    @Published var isAnalyzing = false
    @Published var lastAnalysisResult: AnalysisResult?

    private let sensitivity: AISensitivity
    private let provider: AIProvider
    private let apiEndpoint: String
    private let apiKey: String
    private let modelName: String

    init(
        sensitivity: AISensitivity = .medium,
        provider: AIProvider = .onDevice,
        apiEndpoint: String = "",
        apiKey: String = "",
        modelName: String = ""
    ) {
        self.sensitivity = sensitivity
        self.provider = provider
        self.apiEndpoint = apiEndpoint
        self.apiKey = apiKey
        self.modelName = modelName
    }

    convenience init(settings: AppSettings) {
        self.init(
            sensitivity: settings.aiSensitivity,
            provider: settings.aiProvider,
            apiEndpoint: settings.aiAPIEndpoint,
            apiKey: settings.aiAPIKey,
            modelName: settings.aiModelName
        )
    }

    // MARK: - Analysis Result

    struct AnalysisResult {
        let detections: [Detection]
        let suspiciousQuadrants: Set<String>
        let processingTime: TimeInterval
    }

    // MARK: - Analyze Image

    /// Analyzes an image for suspicious objects.
    /// Routes to on-device Vision framework or external API based on provider setting.
    func analyzeImage(
        _ image: UIImage,
        quadrantId: String,
        zoomLevel: ZoomLevel
    ) async throws -> AnalysisResult {
        await MainActor.run { isAnalyzing = true }
        defer { Task { @MainActor in isAnalyzing = false } }

        let startTime = Date()

        guard let cgImage = image.cgImage else {
            throw AnalysisError.invalidImage
        }

        let detections: [Detection]

        switch provider {
        case .onDevice:
            detections = try await performObjectDetection(
                on: cgImage,
                quadrantId: quadrantId,
                zoomLevel: zoomLevel
            )
        case .customAPI:
            detections = try await performAPIDetection(
                image: image,
                quadrantId: quadrantId,
                zoomLevel: zoomLevel
            )
        }

        let suspiciousQuadrants = Set(
            detections
                .filter { $0.confidence >= sensitivity.confidenceThreshold }
                .map { $0.quadrantId }
        )

        let result = AnalysisResult(
            detections: detections,
            suspiciousQuadrants: suspiciousQuadrants,
            processingTime: Date().timeIntervalSince(startTime)
        )

        await MainActor.run { lastAnalysisResult = result }
        return result
    }

    // MARK: - Object Detection

    /// Uses Vision framework's built-in object recognition.
    /// For production, replace with custom CoreML model (e.g., YOLOv8 trained on OXA data).
    private func performObjectDetection(
        on image: CGImage,
        quadrantId: String,
        zoomLevel: ZoomLevel
    ) async throws -> [Detection] {
        try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeAnimalsRequest { request, error in
                // Using VNRecognizeAnimalsRequest as placeholder.
                // In production, use VNCoreMLRequest with custom OXA model.
                if let error = error {
                    continuation.resume(throwing: AnalysisError.detectionFailed(error.localizedDescription))
                    return
                }
                continuation.resume(returning: [])
            }

            // Also run rectangle detection (catches metallic/box-like objects)
            let rectangleRequest = VNDetectRectanglesRequest()
            rectangleRequest.minimumAspectRatio = 0.2
            rectangleRequest.maximumAspectRatio = 1.0
            rectangleRequest.minimumSize = 0.05
            rectangleRequest.maximumObservations = 10

            // Saliency detection to find unusual/attention-drawing regions
            let saliencyRequest = VNGenerateObjectnessBasedSaliencyImageRequest()

            let handler = VNImageRequestHandler(cgImage: image, options: [:])

            do {
                try handler.perform([rectangleRequest, saliencyRequest])

                var detections: [Detection] = []

                // Process rectangle detections
                if let rectangleResults = rectangleRequest.results {
                    for observation in rectangleResults {
                        let bbox = observation.boundingBox
                        let confidence = observation.confidence

                        if confidence >= self.sensitivity.confidenceThreshold {
                            let detection = Detection(
                                quadrantId: quadrantId,
                                type: .metallic,
                                confidence: confidence,
                                description: "Rektangulärt föremål detekterat",
                                boundingBox: CGRect(
                                    x: bbox.origin.x,
                                    y: bbox.origin.y,
                                    width: bbox.size.width,
                                    height: bbox.size.height
                                )
                            )
                            detections.append(detection)
                        }
                    }
                }

                // Process saliency results
                if let saliencyResults = saliencyRequest.results,
                   let saliency = saliencyResults.first {
                    if let salientObjects = saliency.salientObjects {
                        for object in salientObjects {
                            let bbox = object.boundingBox
                            if object.confidence >= self.sensitivity.confidenceThreshold {
                                let detection = Detection(
                                    quadrantId: quadrantId,
                                    type: .unknown,
                                    confidence: object.confidence,
                                    description: "Misstänkt område identifierat via saliensanalys",
                                    boundingBox: CGRect(
                                        x: bbox.origin.x,
                                        y: bbox.origin.y,
                                        width: bbox.size.width,
                                        height: bbox.size.height
                                    )
                                )
                                detections.append(detection)
                            }
                        }
                    }
                }

                continuation.resume(returning: detections)
            } catch {
                continuation.resume(throwing: AnalysisError.detectionFailed(error.localizedDescription))
            }
        }
    }

    // MARK: - External API Detection

    /// Sends image to an external API for analysis.
    /// The API is expected to return JSON with a "detections" array.
    private func performAPIDetection(
        image: UIImage,
        quadrantId: String,
        zoomLevel: ZoomLevel
    ) async throws -> [Detection] {
        guard !apiEndpoint.isEmpty, let url = URL(string: apiEndpoint) else {
            throw AnalysisError.detectionFailed("Ingen API-endpoint konfigurerad. Gå till Inställningar > AI-konfiguration.")
        }

        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw AnalysisError.invalidImage
        }

        let boundary = UUID().uuidString
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        if !apiKey.isEmpty {
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        }

        // Build multipart body
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"scan.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)

        // Add metadata
        let metadata: [String: String] = [
            "quadrant_id": quadrantId,
            "zoom_level": "\(zoomLevel.rawValue)",
            "sensitivity": "\(sensitivity.confidenceThreshold)",
            "model": modelName
        ]
        for (key, value) in metadata {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            throw AnalysisError.detectionFailed("API svarade med status \(statusCode)")
        }

        return try parseAPIResponse(data, quadrantId: quadrantId)
    }

    /// Parses the API response JSON into Detection objects.
    /// Expected format: { "detections": [{ "type": "...", "confidence": 0.9, "bbox": [x,y,w,h], "description": "..." }] }
    private func parseAPIResponse(_ data: Data, quadrantId: String) throws -> [Detection] {
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let detectionsArray = json["detections"] as? [[String: Any]] else {
            return []
        }

        return detectionsArray.compactMap { dict -> Detection? in
            guard let confidence = (dict["confidence"] as? NSNumber)?.floatValue,
                  confidence >= sensitivity.confidenceThreshold else {
                return nil
            }

            let typeString = dict["type"] as? String ?? "unknown"
            let type: DetectionType = switch typeString {
            case "oxa", "misstänkt_oxa": .suspectedOXA
            case "metallic", "metalliskt_föremål": .metallic
            case "cylindrical", "cylindriskt_föremål": .cylindrical
            default: .unknown
            }

            let bbox: CGRect
            if let bboxArray = dict["bbox"] as? [Double], bboxArray.count == 4 {
                bbox = CGRect(x: bboxArray[0], y: bboxArray[1], width: bboxArray[2], height: bboxArray[3])
            } else {
                bbox = .zero
            }

            let description = dict["description"] as? String ?? type.displayName

            return Detection(
                quadrantId: quadrantId,
                type: type,
                confidence: confidence,
                description: description,
                boundingBox: bbox
            )
        }
    }

    // MARK: - Analyze Quadrants

    /// Analyzes an image and maps detections to quadrant regions.
    func analyzeQuadrants(
        _ image: UIImage,
        parentQuadrantId: String,
        zoomLevel: ZoomLevel
    ) async throws -> [String: [Detection]] {
        let result = try await analyzeImage(image, quadrantId: parentQuadrantId, zoomLevel: zoomLevel)

        var quadrantDetections: [String: [Detection]] = [:]

        for detection in result.detections {
            // Map detection to specific sub-quadrant based on bounding box position
            let subQuadrantRow = detection.boundingBox.midY > 0.5 ? 0 : 1
            let subQuadrantCol = detection.boundingBox.midX > 0.5 ? 1 : 0
            let subQuadrantId = "\(parentQuadrantId)-\(subQuadrantRow)\(subQuadrantCol)"

            var existing = quadrantDetections[subQuadrantId] ?? []
            existing.append(detection)
            quadrantDetections[subQuadrantId] = existing
        }

        return quadrantDetections
    }
}

// MARK: - Analysis Errors

enum AnalysisError: LocalizedError {
    case invalidImage
    case modelNotFound
    case detectionFailed(String)

    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "Ogiltig bild för analys"
        case .modelNotFound:
            return "AI-modell ej hittad"
        case .detectionFailed(let msg):
            return "Detektion misslyckades: \(msg)"
        }
    }
}
