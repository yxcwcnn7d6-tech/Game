import AVFoundation
import UIKit
import Combine

// MARK: - Camera Manager

class CameraManager: NSObject, ObservableObject {
    @Published var isRunning = false
    @Published var currentZoomFactor: CGFloat = 1.0
    @Published var capturedPhoto: UIImage?
    @Published var error: CameraError?

    let session = AVCaptureSession()
    private var videoDeviceInput: AVCaptureDeviceInput?
    private let photoOutput = AVCapturePhotoOutput()
    private var photoContinuation: CheckedContinuation<UIImage, Error>?

    var maxZoomFactor: CGFloat {
        videoDeviceInput?.device.activeFormat.videoMaxZoomFactor ?? 5.0
    }

    // MARK: - Setup

    func configure() {
        session.beginConfiguration()
        session.sessionPreset = .photo

        // Select back camera
        guard let videoDevice = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .back
        ) else {
            error = .noCameraAvailable
            session.commitConfiguration()
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: videoDevice)
            if session.canAddInput(input) {
                session.addInput(input)
                videoDeviceInput = input
            }

            if session.canAddOutput(photoOutput) {
                session.addOutput(photoOutput)
                photoOutput.isHighResolutionCaptureEnabled = true
                photoOutput.maxPhotoQualityPrioritization = .quality
            }
        } catch {
            self.error = .configurationFailed(error.localizedDescription)
        }

        session.commitConfiguration()
    }

    func start() {
        guard !session.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.startRunning()
            DispatchQueue.main.async {
                self?.isRunning = true
            }
        }
    }

    func stop() {
        guard session.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.stopRunning()
            DispatchQueue.main.async {
                self?.isRunning = false
            }
        }
    }

    // MARK: - Zoom Control

    func setZoom(_ factor: CGFloat) {
        guard let device = videoDeviceInput?.device else { return }
        let clampedFactor = min(max(factor, 1.0), min(maxZoomFactor, 10.0))

        do {
            try device.lockForConfiguration()
            device.videoZoomFactor = clampedFactor
            device.unlockForConfiguration()
            DispatchQueue.main.async {
                self.currentZoomFactor = clampedFactor
            }
        } catch {
            self.error = .zoomFailed
        }
    }

    func setZoomLevel(_ level: ZoomLevel) {
        setZoom(level.zoomFactor)
    }

    // MARK: - Photo Capture

    func capturePhoto() async throws -> UIImage {
        try await withCheckedThrowingContinuation { continuation in
            self.photoContinuation = continuation

            let settings = AVCapturePhotoSettings()
            settings.isHighResolutionPhotoEnabled = true

            photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }

    // MARK: - Focus

    func focus(at point: CGPoint) {
        guard let device = videoDeviceInput?.device,
              device.isFocusPointOfInterestSupported else { return }

        do {
            try device.lockForConfiguration()
            device.focusPointOfInterest = point
            device.focusMode = .autoFocus
            if device.isExposurePointOfInterestSupported {
                device.exposurePointOfInterest = point
                device.exposureMode = .autoExpose
            }
            device.unlockForConfiguration()
        } catch {
            self.error = .focusFailed
        }
    }
}

// MARK: - AVCapturePhotoCaptureDelegate

extension CameraManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        if let error = error {
            photoContinuation?.resume(throwing: CameraError.captureFailed(error.localizedDescription))
            photoContinuation = nil
            return
        }

        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else {
            photoContinuation?.resume(throwing: CameraError.captureFailed("No image data"))
            photoContinuation = nil
            return
        }

        DispatchQueue.main.async {
            self.capturedPhoto = image
        }
        photoContinuation?.resume(returning: image)
        photoContinuation = nil
    }
}

// MARK: - Camera Errors

enum CameraError: LocalizedError {
    case noCameraAvailable
    case configurationFailed(String)
    case captureFailed(String)
    case zoomFailed
    case focusFailed
    case permissionDenied

    var errorDescription: String? {
        switch self {
        case .noCameraAvailable:
            return "Ingen kamera tillgänglig"
        case .configurationFailed(let msg):
            return "Kamerakonfiguration misslyckades: \(msg)"
        case .captureFailed(let msg):
            return "Fototagning misslyckades: \(msg)"
        case .zoomFailed:
            return "Zoom misslyckades"
        case .focusFailed:
            return "Fokusering misslyckades"
        case .permissionDenied:
            return "Kameraåtkomst nekad"
        }
    }
}
