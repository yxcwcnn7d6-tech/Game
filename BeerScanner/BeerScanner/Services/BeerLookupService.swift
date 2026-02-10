import UIKit

class BeerLookupService: ObservableObject {
    @Published var isScanning = false
    @Published var scanResult: ScanResult?
    @Published var errorMessage: String?

    private let imageRecognition = ImageRecognitionService.shared
    private let database = BeerDatabase.shared

    func scanBeerImage(_ image: UIImage) {
        isScanning = true
        errorMessage = nil
        scanResult = nil

        imageRecognition.recognizeTextWithBarcodes(in: image) { [weak self] texts, barcodes in
            guard let self = self else { return }

            let allTexts = texts + barcodes

            if allTexts.isEmpty {
                self.isScanning = false
                self.errorMessage = "No text could be recognized on the image. Try taking a clearer photo of the beer label."
                return
            }

            if let match = self.database.findBeer(fromTexts: allTexts) {
                self.scanResult = ScanResult(
                    beer: match.beer,
                    recognizedTexts: allTexts,
                    confidence: match.confidence
                )
            } else {
                self.errorMessage = "Could not identify this beer. Recognized text: \(allTexts.prefix(5).joined(separator: ", ")). Try a different angle or ensure the label is clearly visible."
            }

            self.isScanning = false
        }
    }
}
