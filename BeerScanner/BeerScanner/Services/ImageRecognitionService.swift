import UIKit
import Vision

class ImageRecognitionService {
    static let shared = ImageRecognitionService()

    func recognizeText(in image: UIImage, completion: @escaping ([String]) -> Void) {
        guard let cgImage = image.cgImage else {
            completion([])
            return
        }

        let request = VNRecognizeTextRequest { request, error in
            guard error == nil,
                  let observations = request.results as? [VNRecognizedTextObservation] else {
                DispatchQueue.main.async {
                    completion([])
                }
                return
            }

            let texts = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }

            DispatchQueue.main.async {
                completion(texts)
            }
        }

        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["en-US", "de-DE", "fr-FR", "nl-NL", "ja-JP", "it-IT", "es-ES"]
        request.usesLanguageCorrection = true

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }
    }

    func recognizeTextWithBarcodes(in image: UIImage,
                                    completion: @escaping ([String], [String]) -> Void) {
        guard let cgImage = image.cgImage else {
            completion([], [])
            return
        }

        var recognizedTexts: [String] = []
        var recognizedBarcodes: [String] = []

        let textRequest = VNRecognizeTextRequest { request, _ in
            if let observations = request.results as? [VNRecognizedTextObservation] {
                recognizedTexts = observations.compactMap { $0.topCandidates(1).first?.string }
            }
        }
        textRequest.recognitionLevel = .accurate
        textRequest.recognitionLanguages = ["en-US", "de-DE", "fr-FR", "nl-NL"]
        textRequest.usesLanguageCorrection = true

        let barcodeRequest = VNDetectBarcodesRequest { request, _ in
            if let observations = request.results as? [VNBarcodeObservation] {
                recognizedBarcodes = observations.compactMap { $0.payloadStringValue }
            }
        }

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([textRequest, barcodeRequest])
            } catch {
                // Fall through with empty results
            }

            DispatchQueue.main.async {
                completion(recognizedTexts, recognizedBarcodes)
            }
        }
    }
}
