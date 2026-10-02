import Foundation
import UserNotifications
import Testing
@testable import AIChat

@MainActor
struct PushManagerTests {

    @Test("Only fully authorized status returns true", arguments: [UNAuthorizationStatus.notDetermined, .denied, .authorized, .provisional, .ephemeral])
    func isAuthorized_checksNotificationStatus(status: UNAuthorizationStatus) async {
        let service = RecordingPushNotificationService()
        service.status = status
        let manager = PushManager(service: service)

        #expect(await manager.isAuthorized() == (status == .authorized))
        #expect(service.statusCallCount == 1)
        #expect(service.authorizationCallCount == 0)
    }

    @Test("An authorization status error returns false")
    func isAuthorized_whenStatusFails_returnsFalse() async {
        let service = RecordingPushNotificationService()
        service.statusError = ManagerTestError.requested
        let manager = PushManager(service: service)

        #expect(await manager.isAuthorized() == false)
        #expect(service.statusCallCount == 1)
    }

    @Test("Requesting authorization returns the service result", arguments: [false, true])
    func requestAuthorization_returnsServiceResult(granted: Bool) async throws {
        let service = RecordingPushNotificationService()
        service.authorizationGranted = granted
        let manager = PushManager(service: service)

        #expect(try await manager.requestAuthorization() == granted)
        #expect(service.authorizationCallCount == 1)
    }

    @Test("Requesting authorization propagates errors")
    func requestAuthorization_propagatesError() async {
        let service = RecordingPushNotificationService()
        service.authorizationError = ManagerTestError.requested
        let manager = PushManager(service: service)

        await #expect(throws: ManagerTestError.requested) {
            try await manager.requestAuthorization()
        }
        #expect(service.authorizationCallCount == 1)
    }

    @Test("Checking whether authorization can be requested returns the service result", arguments: [false, true])
    func canRequestAuthorization_returnsServiceResult(canRequest: Bool) async {
        let service = RecordingPushNotificationService()
        service.canRequest = canRequest
        let manager = PushManager(service: service)

        #expect(await manager.canRequestAuthorization() == canRequest)
        #expect(service.canRequestCallCount == 1)
        #expect(service.authorizationCallCount == 0)
    }

    @Test("Weekly reminders clear pending notifications first and schedule seven daily requests")
    func schedulePushNotifications_schedulesExpectedWeek() async throws {
        let service = RecordingPushNotificationService()
        let manager = PushManager(service: service)

        try await manager.schedulePushNotificationsForTheNextWeek()

        #expect(service.removePendingCallCount == 1)
        #expect(service.calls == ["remove_pending"] + (1...7).map { "daily-reminder-\($0)" })
        #expect(service.requests.count == 7)
        for (index, request) in service.requests.enumerated() {
            #expect(request.id == "daily-reminder-\(index + 1)")
            #expect(request.title == "AIChat")
            #expect(request.body == "What's on your mind today?")
            #expect(request.sound == true)
            #expect(request.timeInterval == TimeInterval((index + 1) * 86_400))
            #expect(request.repeats == false)
        }
    }

    @Test("A scheduling failure propagates and prevents later reminders", arguments: [1, 4, 7])
    func schedulePushNotifications_stopsAtFailure(failingDay: Int) async {
        let service = RecordingPushNotificationService()
        service.failingRequestID = "daily-reminder-\(failingDay)"
        let manager = PushManager(service: service)

        await #expect(throws: ManagerTestError.requested) {
            try await manager.schedulePushNotificationsForTheNextWeek()
        }
        #expect(service.removePendingCallCount == 1)
        #expect(service.requests.count == failingDay)
        #expect(service.calls == ["remove_pending"] + (1...failingDay).map { "daily-reminder-\($0)" })
    }

    @Test("Scheduling a second week clears the old requests and reuses stable reminder IDs")
    func schedulePushNotifications_replacesPreviousWeek() async throws {
        let service = RecordingPushNotificationService()
        let manager = PushManager(service: service)

        try await manager.schedulePushNotificationsForTheNextWeek()
        try await manager.schedulePushNotificationsForTheNextWeek()

        #expect(service.removePendingCallCount == 2)
        #expect(service.requests.count == 14)
        #expect(service.requests.prefix(7).map(\.id) == service.requests.suffix(7).map(\.id))
        try #require(service.calls.count == 16)
        #expect(service.calls.first == "remove_pending")
        #expect(service.calls[8] == "remove_pending")
    }
}

@MainActor
private final class RecordingPushNotificationService: PushNotificationService {
    var status: UNAuthorizationStatus = .notDetermined
    var statusError: Error?
    var authorizationGranted = false
    var authorizationError: Error?
    var canRequest = false
    var failingRequestID: String?
    var statusCallCount = 0
    var authorizationCallCount = 0
    var canRequestCallCount = 0
    var removePendingCallCount = 0
    var requests: [PushNotificationRequest] = []
    var calls: [String] = []

    func getNotificationStatus() async throws -> UNAuthorizationStatus {
        statusCallCount += 1
        if let statusError { throw statusError }
        return status
    }

    func requestAuthorization() async throws -> Bool {
        authorizationCallCount += 1
        if let authorizationError { throw authorizationError }
        return authorizationGranted
    }

    func canRequestAuthorization() async -> Bool {
        canRequestCallCount += 1
        return canRequest
    }

    func removeAllPendingNotifications() {
        removePendingCallCount += 1
        calls.append("remove_pending")
    }

    func scheduleNotification(request: PushNotificationRequest) async throws {
        calls.append(request.id)
        requests.append(request)
        if request.id == failingRequestID { throw ManagerTestError.requested }
    }
}
