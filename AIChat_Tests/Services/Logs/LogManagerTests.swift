import Testing
@testable import AIChat

@MainActor
struct LogManagerTests {

    @Test("Identification reaches every logging service with all supplied fields")
    func identifyUser_forwardsToAllServices() throws {
        let services = [RecordingLogService(), RecordingLogService()]
        let manager = LogManager(services: services)

        manager.identifyUser(userId: "user_123", name: "Youssef", email: "user@example.com")

        for service in services {
            #expect(service.identities.count == 1)
            let identity = try #require(service.identities.first)
            #expect(identity.userId == "user_123")
            #expect(identity.name == "Youssef")
            #expect(identity.email == "user@example.com")
        }
    }

    @Test("Identification preserves nil name and email")
    func identifyUser_preservesOptionalFields() throws {
        let service = RecordingLogService()
        let manager = LogManager(services: [service])

        manager.identifyUser(userId: "anonymous", name: nil, email: nil)

        let identity = try #require(service.identities.first)
        #expect(identity.userId == "anonymous")
        #expect(identity.name == nil)
        #expect(identity.email == nil)
    }

    @Test("User properties and their priority reach every service", arguments: [false, true])
    func addUserProperties_forwardsPropertiesAndPriority(isHighPriority: Bool) throws {
        let services = [RecordingLogService(), RecordingLogService()]
        let manager = LogManager(services: services)

        manager.addUserProperties(properties: ["count": 0, "is_new_user": false], isHighPriority: isHighPriority)

        for service in services {
            #expect(service.userProperties.count == 1)
            let call = try #require(service.userProperties.first)
            #expect(call.properties.count == 2)
            #expect(call.properties["count"] as? Int == 0)
            #expect(call.properties["is_new_user"] as? Bool == false)
            if isHighPriority {
                withKnownIssue("LogManager currently ignores isHighPriority and always forwards false.") {
                    #expect(call.isHighPriority == true)
                }
            } else {
                #expect(call.isHighPriority == false)
            }
        }
    }

    @Test("Deleting a profile reaches every service once")
    func deleteUserProfile_forwardsToAllServices() {
        let services = [RecordingLogService(), RecordingLogService()]
        let manager = LogManager(services: services)

        manager.deleteUserProfile()

        for service in services {
            #expect(service.deleteProfileCallCount == 1)
        }
    }

    @Test("Tracking by name defaults to an analytic event without parameters")
    func trackEvent_byName_usesDefaults() throws {
        let services = [RecordingLogService(), RecordingLogService()]
        let manager = LogManager(services: services)

        manager.trackEvent(eventName: "manager_event")

        for service in services {
            #expect(service.events.count == 1)
            let event = try #require(service.events.first)
            #expect(event.name == "manager_event")
            #expect(event.type == .analytic)
            #expect(event.parameters == nil)
            #expect(service.screenEvents.isEmpty)
        }
    }

    @Test("Tracking by name preserves explicit parameters and event type")
    func trackEvent_byName_preservesExplicitValues() throws {
        let services = [RecordingLogService(), RecordingLogService()]
        let manager = LogManager(services: services)

        manager.trackEvent(eventName: "manager_event", parameters: ["chat_id": "chat_123"], type: .warning)

        for service in services {
            #expect(service.events.count == 1)
            let event = try #require(service.events.first)
            #expect(event.name == "manager_event")
            #expect(event.type == .warning)
            #expect(event.parameters?["chat_id"] as? String == "chat_123")
        }
    }

    @Test("Tracking a concrete event forwards its values to every service")
    func trackEvent_concreteEvent_forwardsToAllServices() throws {
        let services = [RecordingLogService(), RecordingLogService()]
        let manager = LogManager(services: services)
        let original = AnyLoggableEvent(eventName: "concrete_event", parameters: [:], type: .info)

        manager.trackEvent(event: original)

        for service in services {
            #expect(service.events.count == 1)
            let event = try #require(service.events.first)
            #expect(event.name == "concrete_event")
            #expect(event.type == .info)
            #expect(event.parameters?.isEmpty == true)
        }
    }

    @Test("Tracking through the protocol forwards its values to every service")
    func trackEvent_protocolEvent_forwardsToAllServices() throws {
        let services = [RecordingLogService(), RecordingLogService()]
        let manager = LogManager(services: services)
        let original: any LoggableEvent = AnyLoggableEvent(eventName: "protocol_event", parameters: ["count": 3], type: .severe)

        manager.trackEvent(event: original)

        for service in services {
            #expect(service.events.count == 1)
            let event = try #require(service.events.first)
            #expect(event.name == "protocol_event")
            #expect(event.type == .severe)
            #expect(event.parameters?["count"] as? Int == 3)
        }
    }

    @Test("Screen events reach the screen method on every service")
    func trackScreenEvent_forwardsToAllServices() throws {
        let services = [RecordingLogService(), RecordingLogService()]
        let manager = LogManager(services: services)
        let original = AnyLoggableEvent(eventName: "chat_screen", parameters: ["chat_id": "chat_123"])

        manager.trackScreenEvent(event: original)

        for service in services {
            #expect(service.screenEvents.count == 1)
            let event = try #require(service.screenEvents.first)
            #expect(event.name == "chat_screen")
            #expect(event.type == .analytic)
            #expect(event.parameters?["chat_id"] as? String == "chat_123")
            #expect(service.events.isEmpty)
        }
    }

    @Test("A manager without logging services accepts every operation")
    func emptyServices_acceptsAllOperations() {
        let manager = LogManager(services: [])

        manager.identifyUser(userId: "user_123", name: nil, email: nil)
        manager.addUserProperties(properties: [:], isHighPriority: true)
        manager.deleteUserProfile()
        manager.trackEvent(eventName: "named_event")
        manager.trackEvent(event: AnyLoggableEvent(eventName: "concrete_event"))
        let event: any LoggableEvent = AnyLoggableEvent(eventName: "protocol_event")
        manager.trackEvent(event: event)
        manager.trackScreenEvent(event: event)
    }
}
