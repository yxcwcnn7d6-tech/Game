import CoreMotion
import Combine

// MARK: - Motion Manager (Gyro stabilization for auto-capture)

class MotionManager: ObservableObject {
    @Published var isStable = false
    @Published var pitch: Double = 0
    @Published var roll: Double = 0
    @Published var yaw: Double = 0

    private let motionManager = CMMotionManager()
    private var stabilityTimer: Timer?
    private var stableStartTime: Date?
    private let requiredStabilityDuration: TimeInterval

    /// Threshold for considering the device "stable" (in radians/sec)
    private let stabilityThreshold: Double = 0.05

    init(stabilityDuration: TimeInterval = 0.5) {
        self.requiredStabilityDuration = stabilityDuration
    }

    // MARK: - Start/Stop

    func startMonitoring() {
        guard motionManager.isDeviceMotionAvailable else { return }

        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let self = self, let motion = motion else { return }

            self.pitch = motion.attitude.pitch
            self.roll = motion.attitude.roll
            self.yaw = motion.attitude.yaw

            let rotationRate = motion.rotationRate
            let totalRotation = abs(rotationRate.x) + abs(rotationRate.y) + abs(rotationRate.z)

            if totalRotation < self.stabilityThreshold {
                if self.stableStartTime == nil {
                    self.stableStartTime = Date()
                }
                let stableDuration = Date().timeIntervalSince(self.stableStartTime!)
                if stableDuration >= self.requiredStabilityDuration && !self.isStable {
                    self.isStable = true
                }
            } else {
                self.stableStartTime = nil
                if self.isStable {
                    self.isStable = false
                }
            }
        }
    }

    func stopMonitoring() {
        motionManager.stopDeviceMotionUpdates()
        isStable = false
        stableStartTime = nil
    }

    deinit {
        stopMonitoring()
    }
}
