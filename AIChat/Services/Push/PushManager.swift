//
//  PushManager.swift
//  AIChat
//
//  Created by Youssef Mohamed on 12/09/2026.
//

import Foundation
import UserNotifications
import SwiftfulUtilities

@MainActor
@Observable
class PushManager {

    func isAuthorized() async -> Bool {
        do {
            let status = try await LocalNotifications.getNotificationStatus()
            return status == .authorized
        } catch {
            return false
        }
    }

    /// called to see if the user wants push notifications or not
    func requestAuthorization() async throws -> Bool {
        try await LocalNotifications.requestAuthorization()
    }

    /// sees if the user didn't take an action yet towards the push notifications allowance
    func canRequestAuthorization() async -> Bool {
        await LocalNotifications.canRequestAuthorization()
    }

    func schedulePushNotificationsForTheNextWeek() async throws {
        LocalNotifications.removeAllPendingNotifications()

        for day in 1...7 {
            let content = AnyNotificationContent(
                id: "daily-reminder-\(day)",
                title: "AIChat",
                body: "What's on your mind today?",
                sound: true
            )

            let trigger = NotificationTriggerOption.time(
                timeInterval: TimeInterval(day * 24 * 60 * 60),
                repeats: false
            )

            try await LocalNotifications.scheduleNotification(
                content: content,
                trigger: trigger
            )
        }
    }
}
