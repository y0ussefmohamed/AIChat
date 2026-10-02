import Foundation
import Testing
@testable import AIChat

@MainActor
struct GroqResponseTests {

    @Test("Decoding an API response preserves choice order and ignores unrelated API metadata")
    func codable_decodesAPIResponse() throws {
        let data = Data("""
        {
            "id": "response_123", "model": "example_model",
            "choices": [
                {"index": 0, "message": {"role": "assistant", "content": "First response"}, "finish_reason": "stop"},
                {"index": 1, "message": {"role": "assistant", "content": "Second response"}, "finish_reason": "stop"}
            ],
            "usage": {"total_tokens": 20}
        }
        """.utf8)
        let response = try JSONDecoder().decode(GroqResponse.self, from: data)

        #expect(response.choices.count == 2)
        #expect(response.choices.map { $0.message.content } == ["First response", "Second response"])
    }

    @Test("An empty choices array is a valid response model")
    func codable_decodesEmptyChoices() throws {
        let response = try JSONDecoder().decode(GroqResponse.self, from: Data(#"{"choices":[]}"#.utf8))

        #expect(response.choices.isEmpty)
    }

    @Test("Codable round trip preserves nested messages")
    func codable_encodesAndDecodesSuccessfully() throws {
        let original = GroqResponse(choices: [Choice(message: Message(content: "Hello 👋")), Choice(message: Message(content: "Second\nline"))])
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(GroqResponse.self, from: data)
        let json = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])

        #expect(Set(json.keys) == ["choices"])
        #expect(decoded.choices.map { $0.message.content } == ["Hello 👋", "Second\nline"])
    }

    @Test("Decoding rejects missing, null, or malformed choices", arguments: [
        #"{}"#,
        #"{"choices":null}"#,
        #"{"choices":{}}"#,
        #"{"choices":[{}]}"#,
        #"{"choices":[{"message":{"content":null}}]}"#
    ])
    func codable_rejectsInvalidPayload(json: String) {
        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(GroqResponse.self, from: Data(json.utf8))
        }
    }
}
