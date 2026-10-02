import Foundation
import UserNotifications
import SwiftfulUtilities

struct PushNotificationRequest {
    let id: String
    let title: String
    let body: String
    let sound: Bool
    let timeInterval: TimeInterval
    let repeats: Bool
}

@MainActor
protocol PushNotificationService {
    func getNotificationStatus() async throws -> UNAuthorizationStatus
    func requestAuthorization() async throws -> Bool
    func canRequestAuthorization() async -> Bool
    func removeAllPendingNotifications()
    func scheduleNotification(request: PushNotificationRequest) async throws
}

@MainActor
struct LocalPushNotificationService: PushNotificationService {
    func getNotificationStatus() async throws -> UNAuthorizationStatus {
        try await LocalNotifications.getNotificationStatus()
    }

    func requestAuthorization() async throws -> Bool {
        try await LocalNotifications.requestAuthorization()
    }

    func canRequestAuthorization() async -> Bool {
        await LocalNotifications.canRequestAuthorization()
    }

    func removeAllPendingNotifications() {
        LocalNotifications.removeAllPendingNotifications()
    }

    func scheduleNotification(request: PushNotificationRequest) async throws {
        try await LocalNotifications.scheduleNotification(
            content: AnyNotificationContent(id: request.id, title: request.title, body: request.body, sound: request.sound),
            trigger: .time(timeInterval: request.timeInterval, repeats: request.repeats)
        )
    }
}
