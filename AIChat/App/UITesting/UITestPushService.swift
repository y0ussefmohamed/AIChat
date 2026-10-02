#if MOCK
import Foundation
import UserNotifications

@MainActor
final class UITestPushService: PushNotificationService {
    private var status: UNAuthorizationStatus

    init(scenario: UITestScenario) {
        status = scenario == .notificationsDenied ? .denied : .notDetermined
    }

    func getNotificationStatus() async throws -> UNAuthorizationStatus { status }
    func canRequestAuthorization() async -> Bool { status == .notDetermined }

    func requestAuthorization() async throws -> Bool {
        status = .authorized
        return true
    }

    func removeAllPendingNotifications() { }
    func scheduleNotification(request: PushNotificationRequest) async throws { }
}
#endif
