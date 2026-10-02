import Foundation
import Testing
@testable import AIChat

@MainActor
struct MessageTests {

    @Test("Message content survives encoding and decoding including empty and Unicode text", arguments: ["", "Hello", "Hello 👋 مرحباً", "First line\nSecond line", "\"Quoted\" text"])
    func codable_preservesContent(content: String) throws {
        let original = Message(content: content)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Message.self, from: data)
        let json = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])

        #expect(decoded.content == content)
        #expect(Set(json.keys) == ["content"])
        #expect(json["content"] as? String == content)
    }

    @Test("Decoding reads content and ignores the API role")
    func codable_decodesContent() throws {
        let data = Data(#"{"role":"assistant","content":"Hello"}"#.utf8)
        let message = try JSONDecoder().decode(Message.self, from: data)

        #expect(message.content == "Hello")
    }

    @Test("Decoding requires string content", arguments: [
        #"{}"#,
        #"{"content":null}"#,
        #"{"content":123}"#,
        #"{"content":[]}"#
    ])
    func codable_rejectsInvalidPayload(json: String) {
        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(Message.self, from: Data(json.utf8))
        }
    }
}
