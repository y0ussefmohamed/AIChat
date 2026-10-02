//
//  PushManager.swift
//  AIChat
//
//  Created by Youssef Mohamed on 12/09/2026.
//

import Foundation
import UserNotifications

@MainActor
@Observable
class PushManager {

    private let service: any PushNotificationService

    init(service: any PushNotificationService = LocalPushNotificationService()) {
        self.service = service
    }

    func isAuthorized() async -> Bool {
        do {
            let status = try await service.getNotificationStatus()
            return status == .authorized
        } catch {
            return false
        }
    }

    /// called to see if the user wants push notifications or not
    func requestAuthorization() async throws -> Bool {
        try await service.requestAuthorization()
    }

    /// sees if the user didn't take an action yet towards the push notifications allowance
    func canRequestAuthorization() async -> Bool {
        await service.canRequestAuthorization()
    }

    func schedulePushNotificationsForTheNextWeek() async throws {
        service.removeAllPendingNotifications()

        for day in 1...7 {
            let request = PushNotificationRequest(
                id: "daily-reminder-\(day)",
                title: "AIChat",
                body: "What's on your mind today?",
                sound: true,
                timeInterval: TimeInterval(day * 24 * 60 * 60),
                repeats: false
            )
            try await service.scheduleNotification(request: request)
        }
    }
}
