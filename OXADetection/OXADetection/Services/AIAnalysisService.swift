import Vision
import UIKit
import CoreML

// MARK: - AI Analysis Service

class AIAnalysisService: ObservableObject {
    @Published var isAnalyzing = false
    @Published var lastAnalysisResult: AnalysisResult?

    private let sensitivity: AISensitivity

    init(sensitivity: AISensitivity = .medium) {
        self.sensitivity = sensitivity
    }

    // MARK: - Analysis Result

    struct AnalysisResult {
        let detections: [Detection]
        let suspiciousQuadrants: Set<String>
        let processingTime: TimeInterval
    }

    // MARK: - Analyze Image

    /// Analyzes an image for suspicious objects using Vision framework object detection.
    /// In production, this would use a custom CoreML model trained on OXA-specific objects.
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

        let detections = try await performObjectDetection(
            on: cgImage,
            quadrantId: quadrantId,
            zoomLevel: zoomLevel
        )

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
