//
//  LiveActivityManagerProtocol.swift
//  NotYourMom
//
//  Created by Gokul P on 1/29/25.
//

import Foundation

protocol LiveActivityManagerProtocol {
    func startLiveActivity(_ contentState: RudePomoWidgetAttributes.ContentState) async
    func stopLiveActivity(_ currentState: SessionState, _ isBreakSession: Bool) async
}
