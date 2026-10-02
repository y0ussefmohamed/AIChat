import Foundation
@testable import AIChat

nonisolated enum ManagerTestError: Error, Equatable {
    case requested
}

@MainActor
func waitForManagerCondition(_ condition: () -> Bool) async -> Bool {
    let clock = ContinuousClock()
    let deadline = clock.now.advanced(by: .seconds(2))
    while !condition() {
        guard clock.now < deadline, !Task.isCancelled else { return false }
        do {
            try await Task.sleep(for: .milliseconds(1))
        } catch {
            return false
        }
    }
    return true
}

@MainActor
final class RecordingLogService: LogService {
    struct Identity {
        let userId: String
        let name: String?
        let email: String?
    }

    struct UserProperties {
        let properties: [String: Any]
        let isHighPriority: Bool
    }

    struct Event {
        let name: String
        let parameters: [String: Any]?
        let type: LogType
    }

    var identities: [Identity] = []
    var userProperties: [UserProperties] = []
    var deleteProfileCallCount = 0
    var events: [Event] = []
    var screenEvents: [Event] = []

    func identifyUser(userId: String, name: String?, email: String?) {
        identities.append(Identity(userId: userId, name: name, email: email))
    }

    func addUserProperties(properties: [String: Any], isHighPriority: Bool) {
        userProperties.append(UserProperties(properties: properties, isHighPriority: isHighPriority))
    }

    func deleteUserProfile() {
        deleteProfileCallCount += 1
    }

    func trackEvent(event: any LoggableEvent) {
        events.append(Event(name: event.eventName, parameters: event.parameters, type: event.type))
    }

    func trackScreenEvent(event: any LoggableEvent) {
        screenEvents.append(Event(name: event.eventName, parameters: event.parameters, type: event.type))
    }
}
