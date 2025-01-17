//
//  NotificationManager.swift
//  NotYourMom
//
//  Created by Gokul P on 1/16/25.
//

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()

    private let messages = [
        "Shouldn't you be working right now?",
        "Put the phone down and do something useful!",
        "Your future self will regret this wasted time.",
        "Is this really the best use of your time?",
        "Your goals aren't going to achieve themselves!",
        "Stop procrastinating!",
        "Are you proud of yourself right now?",
        "This isn't helping your productivity!"
    ]

    private init() {}

    func requestPermission() async throws -> Bool {
        try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .criticalAlert])
    }

    func sendNotification(for state: PhoneMotionManager.PhoneState) {
        let content = UNMutableNotificationContent()
        content.title = "Motion Alert"
        content.body = state == .lifted ? messages.randomElement() ?? "Stay focused!" : "Phone placed down"
        content.sound = .default
        content.interruptionLevel = .critical
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }
}
