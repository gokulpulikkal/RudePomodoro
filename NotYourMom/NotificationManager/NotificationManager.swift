//
//  NotificationManager.swift
//  NotYourMom
//
//  Created by Gokul P on 1/16/25.
//

import Foundation
import UserNotifications

class NotificationManager {

    private let messages = [
        "Shouldn't you be working right now?",
        "Put the phone down and do something useful!",
        "Your future self will regret this wasted time.",
        "Is this really the best use of your time?",
        "Your goals aren't going to achieve themselves!",
        "Stop procrastinating!",
        "Are you proud of yourself right now?",
        "This isn't helping your productivity!",
        "Why are you even checking your phone right now?",
        "Back to work, lazybones!",
        "Oh look, you're wasting time again.",
        "You think success comes from scrolling?",
        "Excuses don’t get things done. Get moving!",
        "Do you even care about your goals?",
        "Guess who’s failing at time management? You.",
        "Your dreams are crying right now.",
        "Procrastination isn’t a personality trait, it’s a choice.",
        "Every second wasted is a step further from success.",
        "Do you really need me to tell you to focus?",
        "Stop being your own worst enemy!",
        "Discipline > motivation. So get back to it!",
        "Daydreaming won’t make you productive.",
        "You can do better. Prove it.",
        "Are you afraid of hard work or just allergic to it?",
        "Keep this up, and you’ll never finish anything.",
        "Go ahead, keep slacking. See how that works out.",
        "You’re better than this. Act like it!",
        "Don’t just sit there wasting time; do something useful!",
        "If you’re reading this, you’re wasting time.",
        "Your competition is working while you’re slacking.",
        "Do you really think this is helping you?",
        "The grind won’t do itself. Get to it!",
        "Are you committed to your excuses or your goals?",
        "Laziness won’t lead you to success.",
        "Nothing changes if nothing changes. Start now.",
        "Netflix can wait. Your goals can’t.",
        "Do you think successful people do this?",
        "You have time for this, but not for your goals?",
        "If your dream job saw this, would they hire you?",
        "No shortcuts. Get back to work.",
        "You’re only cheating yourself right now.",
        "Scrolling isn’t self-care. Work first, rest later.",
        "Does this look like progress to you?",
        "Stop giving up on your future self.",
        "What’s your excuse this time?",
        "Want success? Earn it. Start now.",
        "Every moment wasted is a moment you’ll regret.",
        "Stop pretending this is productive.",
        "Your potential is crying in a corner right now.",
        "You’re capable of more. Show it!"
    ]

    func requestPermission() async throws -> Bool {
        try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .criticalAlert])
    }

    func sendRudeNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Stay focused!"
        content.body = messages.randomElement() ?? "Stay focused!"
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
