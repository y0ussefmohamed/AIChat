import Foundation
import Testing
@testable import AIChat

@MainActor
struct ChatMessageTests {

    @Test("Default chat messages keep the supplied IDs and leave optional fields nil")
    func init_withDefaultValues_setsPropertiesCorrectly() {
        let message = ChatMessage(id: "message_123", chatId: "chat_123")

        #expect(message.id == "message_123")
        #expect(message.chatId == "chat_123")
        #expect(message.authorId == nil)
        #expect(message.content == nil)
        #expect(message.seenByIds == nil)
        #expect(message.dateCreated == nil)
    }

    @Test("Calculated creation date uses the stored date or distantPast")
    func dateCreatedCalculated_resolvesStoredDateOrFallback() {
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let dated = ChatMessage(id: "dated", chatId: "chat_123", dateCreated: date)
        let undated = ChatMessage(id: "undated", chatId: "chat_123")

        #expect(dated.dateCreatedCalculated == date)
        #expect(undated.dateCreatedCalculated == .distantPast)
    }

    @Test("Read status handles nil, empty, matching, and different reader IDs")
    func isSeenBy_checksReaderMembership() {
        let unread = ChatMessage(id: "nil", chatId: "chat_123")
        let empty = ChatMessage(id: "empty", chatId: "chat_123", seenByIds: [])
        let read = ChatMessage(id: "read", chatId: "chat_123", seenByIds: ["user_123", "user_456"])

        #expect(unread.isSeenBy(userId: "user_123") == false)
        #expect(empty.isSeenBy(userId: "user_123") == false)
        #expect(read.isSeenBy(userId: "user_123") == true)
        #expect(read.isSeenBy(userId: "user_456") == true)
        #expect(read.isSeenBy(userId: "user") == false)
        #expect(read.isSeenBy(userId: "USER_123") == false)
    }

    @Test("User message factory assigns the author, content, provided date, and initial reader")
    func newMessageFromUser_setsPropertiesCorrectly() {
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let message = ChatMessage.newMessageFromUser(chatId: "chat_123", userId: "user_123", message: "Hello 👋", dateCreated: date)

        #expect(UUID(uuidString: message.id) != nil)
        #expect(message.chatId == "chat_123")
        #expect(message.authorId == "user_123")
        #expect(message.content == "Hello 👋")
        #expect(message.seenByIds == ["user_123"])
        #expect(message.isSeenBy(userId: "user_123") == true)
        #expect(message.dateCreated == date)
    }

    @Test("Avatar message factory preserves supplied readers and date")
    func newMessageFromAvatar_setsPropertiesCorrectly() {
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let message = ChatMessage.newMessageFromAvatar(
            chatId: "chat_123", avatarId: "avatar_456", message: "Hi!",
            seenByIds: ["user_123", "user_456"], dateCreated: date
        )

        #expect(UUID(uuidString: message.id) != nil)
        #expect(message.chatId == "chat_123")
        #expect(message.authorId == "avatar_456")
        #expect(message.content == "Hi!")
        #expect(message.seenByIds == ["user_123", "user_456"])
        #expect(message.dateCreated == date)
    }

    @Test("Message factories generate unique IDs, current default dates, and no default avatar readers")
    func messageFactories_setDefaultDatesAndUniqueIDs() throws {
        let before = Date()
        let user = ChatMessage.newMessageFromUser(chatId: "chat_123", userId: "user_123", message: "Hello")
        let secondUser = ChatMessage.newMessageFromUser(chatId: "chat_123", userId: "user_123", message: "Hello")
        let avatar = ChatMessage.newMessageFromAvatar(chatId: "chat_123", avatarId: "avatar_456", message: "Hi")
        let secondAvatar = ChatMessage.newMessageFromAvatar(chatId: "chat_123", avatarId: "avatar_456", message: "Hi")
        let after = Date()
        let messages = [user, secondUser, avatar, secondAvatar]

        #expect(Set(messages.map(\.id)).count == messages.count)
        #expect(avatar.seenByIds == [])
        #expect(avatar.isSeenBy(userId: "user_123") == false)
        for message in messages {
            #expect(UUID(uuidString: message.id) != nil)
            let date = try #require(message.dateCreated)
            #expect(date >= before)
            #expect(date <= after)
        }
    }

    @Test("Message factories preserve explicitly nil dates")
    func messageFactories_preserveNilDates() {
        let user = ChatMessage.newMessageFromUser(chatId: "chat_123", userId: "user_123", message: "", dateCreated: nil)
        let avatar = ChatMessage.newMessageFromAvatar(chatId: "chat_123", avatarId: "avatar_456", message: "", dateCreated: nil)

        #expect(user.dateCreated == nil)
        #expect(avatar.dateCreated == nil)
        #expect(user.dateCreatedCalculated == .distantPast)
        #expect(avatar.dateCreatedCalculated == .distantPast)
        #expect(user.content == "")
        #expect(avatar.content == "")
    }

    @Test("Event parameters omit nil fields and preserve populated values")
    func asEventParameter_containsExpectedKeysAndValues() {
        let minimal = ChatMessage(id: "minimal", chatId: "chat_123").asEventParameter
        #expect(Set(minimal.keys) == ["chatMessage_id", "chatMessage_chat_id"])
        #expect(minimal["chatMessage_id"] as? String == "minimal")
        #expect(minimal["chatMessage_chat_id"] as? String == "chat_123")

        let message = makeMessage()
        let parameters = message.asEventParameter
        #expect(Set(parameters.keys) == [
            "chatMessage_id", "chatMessage_chat_id", "chatMessage_author_id",
            "chatMessage_content", "chatMessage_seen_by_ids", "chatMessage_date_created"
        ])
        #expect(parameters["chatMessage_id"] as? String == "message_123")
        #expect(parameters["chatMessage_chat_id"] as? String == "chat_123")
        #expect(parameters["chatMessage_author_id"] as? String == "user_123")
        #expect(parameters["chatMessage_content"] as? String == "Hello 👋")
        #expect(parameters["chatMessage_seen_by_ids"] as? [String] == ["user_123", "user_456"])
        #expect(parameters["chatMessage_date_created"] as? Date == message.dateCreated)

        let empty = ChatMessage(id: "empty", chatId: "chat_123", content: "", seenByIds: []).asEventParameter
        #expect(empty["chatMessage_content"] as? String == "")
        #expect(empty["chatMessage_seen_by_ids"] as? [String] == [])
    }

    @Test("Codable round trip preserves every chat message field")
    func codable_encodesAndDecodesSuccessfully() throws {
        let original = makeMessage()
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ChatMessage.self, from: data)

        #expect(decoded.id == original.id)
        #expect(decoded.chatId == original.chatId)
        #expect(decoded.authorId == original.authorId)
        #expect(decoded.content == original.content)
        #expect(decoded.seenByIds == original.seenByIds)
        #expect(decoded.dateCreated == original.dateCreated)
    }

    @Test("Encoding uses snake_case keys and omits nil optional fields")
    func codable_encodesExpectedKeys() throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        let data = try encoder.encode(makeMessage())
        let json = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])

        #expect(Set(json.keys) == ["id", "chat_id", "author_id", "content", "seen_by_ids", "date_created"])
        #expect(json["id"] as? String == "message_123")
        #expect(json["chat_id"] as? String == "chat_123")
        #expect(json["author_id"] as? String == "user_123")
        #expect(json["content"] as? String == "Hello 👋")
        #expect(json["seen_by_ids"] as? [String] == ["user_123", "user_456"])
        #expect(json["date_created"] as? Double == 1_700_000_000)

        let minimalData = try encoder.encode(ChatMessage(id: "minimal", chatId: "chat_123"))
        let minimalJSON = try #require(JSONSerialization.jsonObject(with: minimalData) as? [String: Any])
        #expect(Set(minimalJSON.keys) == ["id", "chat_id"])
    }

    @Test("Decoding persisted messages maps snake_case keys")
    func codable_decodesFromCustomCodingKeysJSON() throws {
        let data = Data("""
        {"id":"message_123","chat_id":"chat_123","author_id":"user_123",
         "content":"Hello 👋","seen_by_ids":["user_123","user_456"],"date_created":1700000000}
        """.utf8)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        let decoded = try decoder.decode(ChatMessage.self, from: data)

        #expect(decoded.id == "message_123")
        #expect(decoded.chatId == "chat_123")
        #expect(decoded.authorId == "user_123")
        #expect(decoded.content == "Hello 👋")
        #expect(decoded.seenByIds == ["user_123", "user_456"])
        #expect(decoded.dateCreated == Date(timeIntervalSince1970: 1_700_000_000))
    }

    @Test("Optional message fields may be missing or null", arguments: [
        #"{"id":"minimal","chat_id":"chat_123"}"#,
        #"{"id":"minimal","chat_id":"chat_123","author_id":null,"content":null,"seen_by_ids":null,"date_created":null}"#
    ])
    func codable_decodesMinimalMessage(json: String) throws {
        let decoded = try JSONDecoder().decode(ChatMessage.self, from: Data(json.utf8))

        #expect(decoded.id == "minimal")
        #expect(decoded.chatId == "chat_123")
        #expect(decoded.authorId == nil)
        #expect(decoded.content == nil)
        #expect(decoded.seenByIds == nil)
        #expect(decoded.dateCreated == nil)
    }

    @Test("Decoding rejects missing IDs and malformed reader lists", arguments: [
        #"{"chat_id":"chat_123"}"#,
        #"{"id":"message_123"}"#,
        #"{"id":"message_123","chat_id":"chat_123","seen_by_ids":"user_123"}"#,
        #"{"id":"message_123","chat_id":"chat_123","seen_by_ids":[123]}"#
    ])
    func codable_rejectsInvalidPayload(json: String) {
        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(ChatMessage.self, from: Data(json.utf8))
        }
    }

    @Test("Long conversation previews use supplied participant IDs and unique messages")
    func previewLongConversation_usesSuppliedParticipants() {
        let messages = ChatMessage.previewLongConversation(chatId: "preview_chat", userId: "preview_user", avatarId: "preview_avatar")

        #expect(messages.count > 6)
        #expect(Set(messages.map(\.id)).count == messages.count)
        #expect(messages.contains { $0.authorId == "preview_user" })
        #expect(messages.contains { $0.authorId == "preview_avatar" })
        for message in messages {
            #expect(message.chatId == "preview_chat")
            #expect(message.authorId == "preview_user" || message.authorId == "preview_avatar")
            #expect(message.content?.isEmpty == false)
            #expect(message.dateCreated != nil)
            if message.authorId == "preview_user" {
                #expect(message.isSeenBy(userId: "preview_user") == true)
            }
        }
    }

    private func makeMessage() -> ChatMessage {
        ChatMessage(
            id: "message_123", chatId: "chat_123", authorId: "user_123", content: "Hello 👋",
            seenByIds: ["user_123", "user_456"], dateCreated: Date(timeIntervalSince1970: 1_700_000_000)
        )
    }
}
