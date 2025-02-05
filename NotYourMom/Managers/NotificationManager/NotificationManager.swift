//
//  NotificationManager.swift
//  NotYourMom
//
//  Created by Gokul P on 1/16/25.
//

import Foundation
import UserNotifications

class NotificationManager {

    private let rudeMessages = [
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

    private let successMessages = [
        "Nice work! Your future self is thanking you right now.",
        "You stayed focused, and it paid off! Keep it up!",
        "That’s how you get things done! Keep crushing it!",
        "Discipline wins again! Great job staying on track!",
        "Small wins lead to big success—this was a solid one!",
        "Your productivity just leveled up. Well done!",
        "That was a strong session! Ready for the next challenge?",
        "You're proving to yourself that you can do this!",
        "Success is built one session at a time. Keep going!",
        "You just showed procrastination who's boss!",
        "Boom! Another session in the books. Keep the momentum!",
        "You’re building habits that will take you far!",
        "Stay consistent, and these small wins will turn into something huge!",
        "One step closer to your goals—well done!",
        "You stayed on task, and it shows. Keep pushing forward!",
        "Look at you being all productive! Keep up the great work!",
        "That’s how winners work! Stay on this path!",
        "Great discipline! You’re creating real progress.",
        "Your dedication is paying off—keep stacking these wins!",
        "Success loves consistency, and you’re proving it!",
        "That’s the way to stay committed! Let’s do it again!",
        "You didn’t let distractions win—well done!",
        "Keep showing up, and the results will follow!",
        "A focused mind is a powerful mind. You're proving that!",
        "You’re building something great—one session at a time!",
        "That’s the kind of effort that leads to success!",
        "Another Pomodoro down, another step forward!",
        "You just showed up for yourself, and that matters!",
        "Every session counts, and this one was a win!",
        "Hard work pays off—you’re proving it!",
        "Momentum is on your side now. Keep rolling!",
        "The best investment is in yourself. You’re doing it right!",
        "Your focus was on point! Keep that energy going!",
        "Discipline over distractions—you're making it happen!",
        "Great job! This is how progress is made!",
        "Success is a series of small wins. You just got another!",
        "You just got stronger, smarter, and more focused!",
        "One Pomodoro at a time, you're mastering productivity!",
        "You’re proving that you’re serious about your goals!",
        "The path to success is built on moments like this!"
    ]

    func requestPermission() async throws -> Bool {
        try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .criticalAlert])
    }

    func sendRudeNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Stay focused!"
        content.body = rudeMessages.randomElement() ?? "Stay focused!"
        content.sound = .default
        content.interruptionLevel = .critical
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1.5, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    func sendSuccessNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Pomodoro Session Complete!"
        content.body = successMessages.randomElement() ?? ""
        content.sound = .default
        content.interruptionLevel = .critical
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1.5, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    func sendNotification(_ title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.sound = .default
        content.title = title
        content.body = body
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }
}
