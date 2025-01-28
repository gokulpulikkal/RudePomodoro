//
//  Pomo.swift
//  NotYourMom
//
//  Created by Gokul P on 1/28/25.
//

import Foundation

enum Chilling {}
enum Sleeping {}
enum Angry {}
enum Amazed {}

struct Pomo<State>: ~Copyable {
    private init(motionManager: PhoneMotionManager = .init()) {
        self.motionManager = motionManager
    }

    let motionManager: PhoneMotionManager
}

extension Pomo where State == Chilling {
    init() {
        self.motionManager = .init()
    }

    consuming func switchToSleeping() -> Pomo<Sleeping> {
        // Switch animation to sleep with reference
        Pomo<Sleeping>(motionManager: motionManager)
    }

    func printMe() {
        print("Chilling")
    }
}

extension Pomo where State == Sleeping {

    consuming func switchToAngry() -> Pomo<Angry> {
        // Switch animation to angry with reference
        Pomo<Angry>(motionManager: motionManager)
    }

    consuming func switchToAmazed() -> Pomo<Amazed> {
        // Switch animation to Amazed with reference
        Pomo<Amazed>(motionManager: motionManager)
    }

    func printMe() {
        print("Sleeping")
    }
}

extension Pomo where State == Angry {

    consuming func switchToChilling() -> Pomo<Chilling> {
        // Switch animation to chilling with reference
        Pomo<Chilling>(motionManager: motionManager)
    }

    func printMe() {
        print("Angry")
    }
}

extension Pomo where State == Amazed {

    consuming func switchToChilling() -> Pomo<Chilling> {
        // Switch animation to chilling with reference
        Pomo<Chilling>(motionManager: motionManager)
    }

    func printMe() {
        print("Amazed")
    }
}
