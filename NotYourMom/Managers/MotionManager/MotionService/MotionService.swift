//
//  MotionService.swift
//  NotYourMom
//
//  Created by Gokul P on 1/29/25.
//

import CoreMotion
import Foundation

class MotionService: MotionServiceProtocol {

    var continuation: AsyncStream<CMDeviceMotion>.Continuation?

    func getMotionUpdateStream() -> AsyncStream<CMDeviceMotion> {
        AsyncStream { continuation in
            let motionManager = CMMotionManager()
            continuation.onTermination = { @Sendable [weak self] _ in
                self?.stopMonitoring(motionManager)
            }
            Task.detached { [weak self] in
                self?.startMonitoring(motionManager, continuation)
            }
        }
    }

    func stopStream() {
        continuation?.finish()
    }

    func startMonitoring(_ motionManager: CMMotionManager, _ continuation: AsyncStream<CMDeviceMotion>.Continuation) {
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

    func stopMonitoring(_ motionManager: CMMotionManager) {
        motionManager.stopDeviceMotionUpdates()
    }

}
