import SwiftUI
import AVFoundation

struct CameraOverlayView: View {
    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            // Camera viewfinder overlay
            VStack {
                HStack {
                    Spacer()
                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .shadow(radius: 4)
                    }
                    .padding()
                }

                Spacer()

                // Scanning frame guide
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.beerGold, lineWidth: 3)
                        .frame(width: 280, height: 380)

                    VStack {
                        Image(systemName: "viewfinder")
                            .font(.system(size: 40))
                            .foregroundColor(.beerGold)

                        Text("Align beer can here")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .shadow(radius: 4)
                    }
                }

                Spacer()

                // Bottom hint
                Text("Position the label within the frame")
                    .font(.footnote)
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.6))
                    )
                    .padding(.bottom, 100)
            }
        }
    }
}

struct LiveCameraView: UIViewControllerRepresentable {
    @Binding var capturedImage: UIImage?
    @Binding var isPresented: Bool

    func makeUIViewController(context: Context) -> CameraViewController {
        let controller = CameraViewController()
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, CameraViewControllerDelegate {
        let parent: LiveCameraView

        init(_ parent: LiveCameraView) {
            self.parent = parent
        }

        func didCaptureImage(_ image: UIImage) {
            parent.capturedImage = image
            parent.isPresented = false
        }
    }
}

protocol CameraViewControllerDelegate: AnyObject {
    func didCaptureImage(_ image: UIImage)
}

class CameraViewController: UIViewController {
    weak var delegate: CameraViewControllerDelegate?

    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private let photoOutput = AVCapturePhotoOutput()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        setupUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }

    private func setupCamera() {
        let session = AVCaptureSession()
        session.sessionPreset = .photo

        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: camera) else { return }

        if session.canAddInput(input) {
            session.addInput(input)
        }

        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }

        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)

        self.previewLayer = previewLayer
        self.captureSession = session

        DispatchQueue.global(qos: .userInitiated).async {
            session.startRunning()
        }
    }

    private func setupUI() {
        let captureButton = UIButton(type: .system)
        captureButton.translatesAutoresizingMaskIntoConstraints = false

        let config = UIImage.SymbolConfiguration(pointSize: 70, weight: .light)
        captureButton.setImage(UIImage(systemName: "circle.inset.filled", withConfiguration: config), for: .normal)
        captureButton.tintColor = .white
        captureButton.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)

        view.addSubview(captureButton)

        NSLayoutConstraint.activate([
            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            captureButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
        ])
    }

    @objc private func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession?.stopRunning()
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else { return }
        delegate?.didCaptureImage(image)
    }
}
