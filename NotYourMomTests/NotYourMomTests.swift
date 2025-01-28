//
//  NotYourMomTests.swift
//  NotYourMomTests
//
//  Created by Gokul P on 1/16/25.
//

import Testing
@testable import NotYourMom

struct NotYourMomTests {

    @Test func PomoInit() async throws {
        let chillingPomo = Pomo<Chilling>()
        chillingPomo.printMe()
        let sleepingPomo = chillingPomo.switchToSleeping()
        sleepingPomo.printMe()
        
        let amazedPomo = sleepingPomo.switchToAmazed()
        
    }

}
