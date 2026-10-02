import Foundation
import Testing
@testable import AIChat

@MainActor
struct AnyLoggableEventTests {

    @Test("Events default to analytic type with no parameters")
    func init_withDefaultValues_setsPropertiesCorrectly() {
        let event = AnyLoggableEvent(eventName: "model_event")

        #expect(event.eventName == "model_event")
        #expect(event.type == .analytic)
        #expect(event.parameters == nil)
    }

    @Test("Events preserve an explicit type and mixed parameter values")
    func init_withExplicitValues_preservesParameters() throws {
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let event = AnyLoggableEvent(
            eventName: "model_event",
            parameters: ["user_id": "user_123", "is_new_user": false, "count": 0, "date": date, "ids": ["a", "b"]],
            type: .warning
        )
        let parameters = try #require(event.parameters)

        #expect(event.eventName == "model_event")
        #expect(event.type == .warning)
        #expect(parameters.count == 5)
        #expect(parameters["user_id"] as? String == "user_123")
        #expect(parameters["is_new_user"] as? Bool == false)
        #expect(parameters["count"] as? Int == 0)
        #expect(parameters["date"] as? Date == date)
        #expect(parameters["ids"] as? [String] == ["a", "b"])
    }

    @Test("An explicitly empty parameter dictionary remains present")
    func init_withEmptyParameters_preservesEmptyDictionary() throws {
        let event = AnyLoggableEvent(eventName: "model_event", parameters: [:])
        let parameters = try #require(event.parameters)

        #expect(parameters.isEmpty)
    }

    @Test("Events capture the parameter dictionary value at initialization")
    func init_copiesParameterDictionary() throws {
        var parameters: [String: Any] = ["user_id": "original"]
        let event = AnyLoggableEvent(eventName: "model_event", parameters: parameters)
        parameters["user_id"] = "changed"
        parameters["new_key"] = true
        let stored = try #require(event.parameters)

        #expect(stored["user_id"] as? String == "original")
        #expect(stored["new_key"] == nil)
        #expect(stored.count == 1)
    }

    @Test("Events expose the same values through LoggableEvent")
    func protocolConformance_exposesEventProperties() {
        let event: any LoggableEvent = AnyLoggableEvent(eventName: "model_event", parameters: ["count": 3], type: .severe)

        #expect(event.eventName == "model_event")
        #expect(event.type == .severe)
        #expect(event.parameters?["count"] as? Int == 3)
    }
}
