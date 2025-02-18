//
//  MotionService.swift
//  NotYourMom
//
//  Created by Gokul P on 1/29/25.
//

@preconcurrency import CoreMotion
import Foundation

class MotionService: MotionServiceProtocol {

    private var continuation: AsyncStream<CMDeviceMotion>.Continuation?

    func getMotionUpdateStream() -> AsyncStream<CMDeviceMotion> {
        AsyncStream { continuation in
            let motionManager = CMMotionManager()
            continuation.onTermination = { @Sendable _ in
                motionManager.stopDeviceMotionUpdates()
            }
            startMonitoring(motionManager, continuation)
        }
    }

    func stopStream() {
        continuation?.finish()
    }

    private func startMonitoring(
        _ motionManager: CMMotionManager,
        _ continuation: AsyncStream<CMDeviceMotion>.Continuation
    ) {
        guard motionManager.isDeviceMotionAvailable, !motionManager.isDeviceMotionActive else {
            continuation.finish()
            print("❌ Device motion is not available")
            return
        }
        self.continuation = continuation
        motionManager.startDeviceMotionUpdates(to: OperationQueue()) { [weak self] motion, error in
            guard let motion, error == nil else {
                print("Error: Unknown error receiving motion update \(error!.localizedDescription)")
                self?.stopStream()
                return
            }
            continuation.yield(motion)
        }
    }

}
