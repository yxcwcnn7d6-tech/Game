import SwiftUI
import AVFoundation

// MARK: - Scan View

struct ScanView: View {
    @EnvironmentObject var settings: AppSettings
    @StateObject private var viewModel: ScanViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingReport = false

    init(scanMode: ScanMode) {
        let appSettings = AppSettings.load()
        appSettings.scanMode = scanMode
        _viewModel = StateObject(wrappedValue: ScanViewModel(settings: appSettings))
    }

    var body: some View {
        ZStack {
            // Camera Preview
            CameraPreviewView(session: viewModel.cameraManager.session)
                .ignoresSafeArea()

            // Grid Overlay
            if viewModel.showingGrid {
                GridOverlayView(
                    quadrants: viewModel.session.rootQuadrants,
                    currentQuadrant: viewModel.session.currentQuadrant,
                    completedQuadrants: viewModel.session.completedQuadrants,
                    suspiciousQuadrants: viewModel.session.suspiciousQuadrants,
                    detections: viewModel.currentDetections,
                    onQuadrantTap: { quadrant in
                        if settings.scanMode == .custom {
                            viewModel.selectQuadrant(quadrant)
                        }
                    }
                )
            }

            // Detection markers
            if !viewModel.currentDetections.isEmpty {
                DetectionOverlayView(detections: viewModel.currentDetections)
            }

            // Analysis overlay
            if viewModel.showAnalysisOverlay {
                AnalysisOverlayView()
            }

            // UI Controls
            VStack {
                // Top bar
                HStack {
                    Button {
                        viewModel.teardown()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .shadow(radius: 4)
                    }

                    Spacer()

                    // Phase indicator
                    VStack(spacing: 2) {
                        Text(viewModel.session.scanPhase.displayName)
                            .font(.caption.bold())
                            .foregroundStyle(.orange)
                        if !viewModel.progressText.isEmpty {
                            Text(viewModel.progressText)
                                .font(.caption2)
                                .foregroundStyle(.white.opacity(0.7))
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())

                    Spacer()

                    // Zoom indicator
                    Text("\(viewModel.cameraManager.currentZoomFactor, specifier: "%.1f")x")
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                }
                .padding(.horizontal)
                .padding(.top, 8)

                Spacer()

                // Bottom: Guidance text + capture button
                VStack(spacing: 16) {
                    // Guidance
                    Text(viewModel.guidanceText)
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(.black.opacity(0.6))
                        .clipShape(Capsule())

                    // Stability indicator
                    if settings.autoCaptureEnabled && viewModel.showingGrid {
                        StabilityIndicator(isStable: viewModel.motionManager.isStable)
                    }

                    HStack(spacing: 40) {
                        // Skip button
                        if viewModel.showingGrid {
                            Button {
                                viewModel.skipCurrentQuadrant()
                            } label: {
                                Image(systemName: "forward.fill")
                                    .font(.title3)
                                    .foregroundStyle(.white.opacity(0.7))
                                    .frame(width: 50, height: 50)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Circle())
                            }
                        } else {
                            Spacer().frame(width: 50)
                        }

                        // Capture button
                        Button {
                            Task {
                                if !viewModel.showingGrid {
                                    await viewModel.captureOverview()
                                } else {
                                    await viewModel.captureCurrentQuadrant()
                                }
                            }
                        } label: {
                            ZStack {
                                Circle()
                                    .stroke(.white, lineWidth: 4)
                                    .frame(width: 72, height: 72)
                                Circle()
                                    .fill(.white)
                                    .frame(width: 62, height: 62)
                                if viewModel.isCapturing {
                                    ProgressView()
                                        .tint(.black)
                                }
                            }
                        }
                        .disabled(viewModel.isCapturing)

                        // Report button (when scan complete)
                        if viewModel.scanComplete {
                            Button {
                                showingReport = true
                            } label: {
                                Image(systemName: "doc.text.fill")
                                    .font(.title3)
                                    .foregroundStyle(.orange)
                                    .frame(width: 50, height: 50)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Circle())
                            }
                        } else {
                            Spacer().frame(width: 50)
                        }
                    }
                }
                .padding(.bottom, 30)
            }
        }
        .onAppear {
            viewModel.setup()
        }
        .onDisappear {
            viewModel.teardown()
        }
        .alert("Fel", isPresented: .init(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .fullScreenCover(isPresented: $showingReport) {
            ReportView(report: viewModel.generateReport(), sessionId: viewModel.session.id)
        }
    }
}

// MARK: - Camera Preview (UIKit wrapper)

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> CameraPreviewUIView {
        let view = CameraPreviewUIView()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: CameraPreviewUIView, context: Context) {}
}

class CameraPreviewUIView: UIView {
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    var previewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }
}

// MARK: - Stability Indicator

struct StabilityIndicator: View {
    let isStable: Bool

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(isStable ? Color.green : Color.red)
                .frame(width: 8, height: 8)
            Text(isStable ? "Stabil" : "Stabiliserar...")
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.8))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(.black.opacity(0.5))
        .clipShape(Capsule())
        .animation(.easeInOut(duration: 0.3), value: isStable)
    }
}

// MARK: - Analysis Overlay

struct AnalysisOverlayView: View {
    @State private var rotation: Double = 0

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: "brain")
                    .font(.system(size: 40))
                    .foregroundStyle(.orange)
                    .rotationEffect(.degrees(rotation))
                    .onAppear {
                        withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                            rotation = 360
                        }
                    }

                Text("AI Analyserar...")
                    .font(.headline)
                    .foregroundStyle(.white)

                Text("Söker efter misstänkta objekt")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
            }
            .padding(30)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }
}
