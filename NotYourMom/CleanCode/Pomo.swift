//
//  Pomo.swift
//  NotYourMom
//
//  Created by Gokul P on 1/28/25.
//

import Foundation
import RiveRuntime

enum Chilling {}
enum Sleeping {}
enum Angry {}
enum Amazed {}

struct Pomo<State>: ~Copyable {
    private init(motionManager: PhoneMotionManager = .init(), rivAnimModel: RiveViewModel) {
        self.motionManager = motionManager
        self.rivAnimModel = rivAnimModel
    }

    let motionManager: PhoneMotionManager
    let rivAnimModel: RiveViewModel
}

extension Pomo where State == Chilling {
    init(rivAnimModel: RiveViewModel) {
        self.motionManager = .init()
        self.rivAnimModel = rivAnimModel
    }

    consuming func switchToSleeping() -> Pomo<Sleeping> {
        // Switch animation to sleep with reference
        rivAnimModel.triggerInput("start")
        return Pomo<Sleeping>(motionManager: motionManager, rivAnimModel: rivAnimModel)
    }

    func printMe() {
        print("Chilling")
    }
}

extension Pomo where State == Sleeping {

    consuming func switchToAngry() -> Pomo<Angry> {
        // Switch animation to angry with reference
        rivAnimModel.triggerInput("stop")
        return Pomo<Angry>(motionManager: motionManager, rivAnimModel: rivAnimModel)
    }

    consuming func switchToAmazed() -> Pomo<Amazed> {
        // Switch animation to Amazed with reference
        rivAnimModel.triggerInput("finish")
        return Pomo<Amazed>(motionManager: motionManager, rivAnimModel: rivAnimModel)
    }

    func printMe() {
        print("Sleeping")
    }
}

extension Pomo where State == Angry {

    consuming func switchToChilling() -> Pomo<Chilling> {
        // Switch animation to chilling with reference
        rivAnimModel.triggerInput("reset")
        return Pomo<Chilling>(motionManager: motionManager, rivAnimModel: rivAnimModel)
    }

    func printMe() {
        print("Angry")
    }
}

extension Pomo where State == Amazed {

    consuming func switchToChilling() -> Pomo<Chilling> {
        // Switch animation to chilling with reference
        rivAnimModel.triggerInput("reset")
        return Pomo<Chilling>(motionManager: motionManager, rivAnimModel: rivAnimModel)
    }

    func printMe() {
        print("Amazed")
    }
}
