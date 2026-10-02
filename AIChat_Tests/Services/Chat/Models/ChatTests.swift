import Foundation
import Testing
@testable import AIChat

@MainActor
struct ChatTests {

    @Test("Chat IDs combine the user and avatar IDs in a stable order")
    func chatId_combinesUserAndAvatar() {
        #expect(Chat.chatId(userId: "user_123", avatarId: "avatar_456") == "user_123_avatar_456")
        #expect(Chat.chatId(userId: "user_123", avatarId: "avatar_456") != Chat.chatId(userId: "avatar_456", avatarId: "user_123"))
        #expect(Chat.chatId(userId: "user_123", avatarId: "avatar_456") != Chat.chatId(userId: "user_123", avatarId: "avatar_789"))
    }

    @Test("New chats use the combined ID and initialize both dates to the current time")
    func newChat_setsPropertiesAndDates() {
        let before = Date()
        let chat = Chat.newChat(userId: "user_123", avatarId: "avatar_456")
        let after = Date()

        #expect(chat.id == "user_123_avatar_456")
        #expect(chat.userId == "user_123")
        #expect(chat.avatarId == "avatar_456")
        #expect(chat.dateCreated >= before)
        #expect(chat.dateCreated <= after)
        #expect(chat.dateModified >= chat.dateCreated)
        #expect(chat.dateModified <= after)
    }

    @Test("Event parameters expose prefixed IDs and Unix timestamps")
    func asEventParameter_containsExpectedKeysAndValues() {
        let parameters = makeChat().asEventParameter

        #expect(Set(parameters.keys) == ["chat_id", "chat_user_id", "chat_avatar_id", "chat_date_created", "chat_date_modified"])
        #expect(parameters["chat_id"] as? String == "chat_123")
        #expect(parameters["chat_user_id"] as? String == "user_123")
        #expect(parameters["chat_avatar_id"] as? String == "avatar_456")
        #expect(parameters["chat_date_created"] as? Double == 1_700_000_000)
        #expect(parameters["chat_date_modified"] as? Double == 1_700_000_500)
    }

    @Test("Codable round trip preserves all chat fields")
    func codable_encodesAndDecodesSuccessfully() throws {
        let original = makeChat()
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Chat.self, from: data)

        #expect(decoded.id == original.id)
        #expect(decoded.userId == original.userId)
        #expect(decoded.avatarId == original.avatarId)
        #expect(decoded.dateCreated == original.dateCreated)
        #expect(decoded.dateModified == original.dateModified)
    }

    @Test("Encoding uses the persisted chat schema")
    func codable_encodesExpectedKeys() throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        let data = try encoder.encode(makeChat())
        let json = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])

        #expect(Set(json.keys) == ["id", "user_id", "avatar_id", "date_created", "date_modified"])
        #expect(json["id"] as? String == "chat_123")
        #expect(json["user_id"] as? String == "user_123")
        #expect(json["avatar_id"] as? String == "avatar_456")
        #expect(json["date_created"] as? Double == 1_700_000_000)
        #expect(json["date_modified"] as? Double == 1_700_000_500)
    }

    @Test("Decoding a persisted chat maps snake_case keys and both dates")
    func codable_decodesFromCustomCodingKeysJSON() throws {
        let data = Data("""
        {"id":"chat_123","user_id":"user_123","avatar_id":"avatar_456",
         "date_created":1700000000,"date_modified":1700000500}
        """.utf8)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        let chat = try decoder.decode(Chat.self, from: data)

        #expect(chat.id == "chat_123")
        #expect(chat.userId == "user_123")
        #expect(chat.avatarId == "avatar_456")
        #expect(chat.dateCreated == Date(timeIntervalSince1970: 1_700_000_000))
        #expect(chat.dateModified == Date(timeIntervalSince1970: 1_700_000_500))
    }

    @Test("Every persisted chat field is required", arguments: ["id", "user_id", "avatar_id", "date_created", "date_modified"])
    func codable_rejectsMissingRequiredField(key: String) throws {
        var json: [String: Any] = [
            "id": "chat_123", "user_id": "user_123", "avatar_id": "avatar_456",
            "date_created": 1_700_000_000, "date_modified": 1_700_000_500
        ]
        json.removeValue(forKey: key)
        let data = try JSONSerialization.data(withJSONObject: json)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970

        #expect(throws: DecodingError.self) {
            try decoder.decode(Chat.self, from: data)
        }
    }

    private func makeChat() -> Chat {
        Chat(
            id: "chat_123", userId: "user_123", avatarId: "avatar_456",
            dateCreated: Date(timeIntervalSince1970: 1_700_000_000),
            dateModified: Date(timeIntervalSince1970: 1_700_000_500)
        )
    }
}
