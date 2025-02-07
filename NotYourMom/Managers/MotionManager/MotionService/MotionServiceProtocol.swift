//
//  MotionServiceProtocol.swift
//  NotYourMom
//
//  Created by Gokul P on 1/29/25.
//

import Foundation
import CoreMotion

protocol MotionServiceProtocol {
    func getMotionUpdateStream() -> AsyncStream<CMDeviceMotion>
    func stopStream()
}
