//
//  PomoState.swift
//  NotYourMom
//
//  Created by Gokul P on 1/28/25.
//

import Foundation
import RiveRuntime

enum PomoState: ~Copyable {
    case chilling(Pomo<Chilling>)
    case sleeping(Pomo<Sleeping>)
    case angry(Pomo<Angry>)
    case amazed(Pomo<Amazed>)

    init(animationModel: RiveViewModel) {
        self = .chilling(Pomo<Chilling>(rivAnimModel: animationModel))
    }

    mutating func switchToSleeping() {
        switch consume self {
        case let .chilling(pomo):
            self = .sleeping(pomo.switchToSleeping())
        case let .sleeping(pomo):
            self = .sleeping(pomo)
        case let .angry(pomo):
            self = .angry(pomo)
        case let .amazed(pomo):
            self = .amazed(pomo)
        }
    }

    mutating func switchToAngry() {
        switch consume self {
        case let .chilling(pomo):
            self = .chilling(pomo)
        case let .sleeping(pomo):
            self = .angry(pomo.switchToAngry())
        case let .angry(pomo):
            self = .angry(pomo)
        case let .amazed(pomo):
            self = .amazed(pomo)
        }
    }

    mutating func switchToAmazed() {
        switch consume self {
        case let .chilling(pomo):
            self = .chilling(pomo)
        case let .sleeping(pomo):
            self = .sleeping(pomo)
        case let .angry(pomo):
            self = .angry(pomo)
        case let .amazed(pomo):
            self = .amazed(pomo)
        }
    }

    mutating func switchToChilling() {
        switch consume self {
        case let .chilling(pomo):
            self = .chilling(pomo)
        case let .sleeping(pomo):
            self = .sleeping(pomo)
        case let .angry(pomo):
            self = .chilling(pomo.switchToChilling())
        case let .amazed(pomo):
            self = .chilling(pomo.switchToChilling())
        }
    }

}
