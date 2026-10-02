import Foundation
import Testing
@testable import AIChat

@MainActor
struct ChoiceTests {

    @Test("Decoding a choice reads its message and ignores additional API fields")
    func codable_decodesMessage() throws {
        let data = Data(#"{"index":0,"message":{"role":"assistant","content":"Hello"},"finish_reason":"stop"}"#.utf8)
        let choice = try JSONDecoder().decode(Choice.self, from: data)

        #expect(choice.message.content == "Hello")
    }

    @Test("Codable round trip preserves the message and encodes the nested schema")
    func codable_encodesAndDecodesSuccessfully() throws {
        let original = Choice(message: Message(content: "Hello 👋"))
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Choice.self, from: data)
        let json = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
        let message = try #require(json["message"] as? [String: Any])

        #expect(decoded.message.content == original.message.content)
        #expect(Set(json.keys) == ["message"])
        #expect(Set(message.keys) == ["content"])
        #expect(message["content"] as? String == "Hello 👋")
    }

    @Test("Decoding rejects a missing, null, or malformed message", arguments: [
        #"{}"#,
        #"{"message":null}"#,
        #"{"message":"Hello"}"#,
        #"{"message":{}}"#
    ])
    func codable_rejectsInvalidPayload(json: String) {
        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(Choice.self, from: Data(json.utf8))
        }
    }
}
