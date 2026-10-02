import Foundation
import Testing
@testable import AIChat

@MainActor
struct ChatManagerTests {

    @Test("Streaming forwards the chat ID and preserves successive message batches")
    func streamChatChanges_returnsServiceBatches() async throws {
        let service = RecordingChatService()
        let first = ChatMessage(id: "message_1", chatId: "chat_123", content: "Hello")
        let second = ChatMessage(id: "message_2", chatId: "chat_123", content: "Hi")
        service.messageBatches = [[], [first], [first, second]]
        let manager = ChatManager(service: service)
        var received: [[ChatMessage]] = []

        for try await batch in manager.streamChatChanges(chatId: "chat_123") {
            received.append(batch)
        }

        #expect(received.map { $0.map(\.id) } == [[], ["message_1"], ["message_1", "message_2"]])
        #expect(received.last?.last?.content == "Hi")
        #expect(service.calls == ["stream:chat_123"])
    }

    @Test("Streaming propagates an error after previously emitted messages")
    func streamChatChanges_propagatesStreamError() async {
        let service = RecordingChatService()
        service.messageBatches = [[ChatMessage(id: "message_1", chatId: "chat_123")]]
        service.streamError = ManagerTestError.requested
        let manager = ChatManager(service: service)
        var receivedIDs: [String] = []

        await #expect(throws: ManagerTestError.requested) {
            for try await batch in manager.streamChatChanges(chatId: "chat_123") {
                receivedIDs.append(contentsOf: batch.map(\.id))
            }
        }
        #expect(receivedIDs == ["message_1"])
        #expect(service.calls == ["stream:chat_123"])
    }

    @Test("Creating a chat forwards every model field")
    func createNewChat_forwardsChat() async throws {
        let service = RecordingChatService()
        let manager = ChatManager(service: service)
        let chat = makeChat()

        try await manager.createNewChat(chat: chat)

        let saved = try #require(service.createdChat)
        #expect(saved.id == chat.id)
        #expect(saved.userId == chat.userId)
        #expect(saved.avatarId == chat.avatarId)
        #expect(saved.dateCreated == chat.dateCreated)
        #expect(saved.dateModified == chat.dateModified)
        #expect(service.calls == ["create:chat_123"])
    }

    @Test("Adding a message forwards every message field")
    func addChatMessage_forwardsMessage() async throws {
        let service = RecordingChatService()
        let manager = ChatManager(service: service)
        let message = ChatMessage(id: "message_123", chatId: "chat_123", authorId: "user_123", content: "Hello", seenByIds: ["user_123"], dateCreated: Date(timeIntervalSince1970: 1_700_000_000))

        try await manager.addChatMessage(message: message)

        let saved = try #require(service.addedMessage)
        #expect(saved.id == message.id)
        #expect(saved.chatId == message.chatId)
        #expect(saved.authorId == message.authorId)
        #expect(saved.content == message.content)
        #expect(saved.seenByIds == message.seenByIds)
        #expect(saved.dateCreated == message.dateCreated)
        #expect(service.calls == ["add:message_123"])
    }

    @Test("Loading a chat forwards both participant IDs and returns the service model")
    func loadChat_returnsServiceChat() async throws {
        let service = RecordingChatService()
        service.chat = makeChat()
        let manager = ChatManager(service: service)

        let chat = try #require(try await manager.loadChat(userId: "user_123", avatarId: "avatar_456"))

        #expect(chat.id == "chat_123")
        #expect(chat.userId == "user_123")
        #expect(chat.avatarId == "avatar_456")
        #expect(service.calls == ["load:user_123:avatar_456"])
    }

    @Test("Loading a nonexistent chat preserves a nil result")
    func loadChat_preservesNilResult() async throws {
        let service = RecordingChatService()
        let manager = ChatManager(service: service)

        #expect(try await manager.loadChat(userId: "user_123", avatarId: "avatar_456") == nil)
        #expect(service.calls == ["load:user_123:avatar_456"])
    }

    @Test("Loading a user's chats preserves returned order and empty lists", arguments: [false, true])
    func loadChats_returnsServiceList(isEmpty: Bool) async throws {
        let service = RecordingChatService()
        service.chats = isEmpty ? [] : [makeChat(id: "second"), makeChat(id: "first")]
        let manager = ChatManager(service: service)

        let chats = try await manager.loadChats(userId: "user_123")

        #expect(chats.map(\.id) == service.chats.map(\.id))
        #expect(service.calls == ["load_all:user_123"])
    }

    @Test("Marking a message seen forwards the message, chat, and user IDs")
    func userHasSeenMessage_forwardsAllIDs() async throws {
        let service = RecordingChatService()
        let manager = ChatManager(service: service)

        try await manager.userHasSeenMessage(messageId: "message_123", chatId: "chat_123", userId: "user_123")

        #expect(service.calls == ["seen:message_123:chat_123:user_123"])
    }

    @Test("Deleting one chat forwards only its chat ID")
    func deleteChat_forwardsChatID() async throws {
        let service = RecordingChatService()
        let manager = ChatManager(service: service)

        try await manager.deleteChat(chatId: "chat_123")

        #expect(service.calls == ["delete:chat_123"])
    }

    @Test("Deleting all chats forwards the user's ID")
    func deleteAllChats_forwardsUserID() async throws {
        let service = RecordingChatService()
        let manager = ChatManager(service: service)

        try await manager.deleteAllChats(userId: "user_123")

        #expect(service.calls == ["delete_all:user_123"])
    }

    @Test("Reporting an existing chat forwards the chat and user IDs")
    func reportChat_forwardsIDs() async throws {
        let service = RecordingChatService()
        let manager = ChatManager(service: service)

        try await manager.reportChat(chatId: "chat_123", userId: "user_123")

        #expect(service.calls == ["report:chat_123:user_123"])
    }

    @Test("Reporting a nil chat ID performs no service call even if the service would fail")
    func reportChat_withNilID_doesNothing() async throws {
        let service = RecordingChatService()
        service.error = ManagerTestError.requested
        let manager = ChatManager(service: service)

        try await manager.reportChat(chatId: nil, userId: "user_123")

        #expect(service.calls.isEmpty)
    }

    @Test("Every asynchronous chat operation propagates service errors", arguments: ["create", "add", "load", "load_all", "seen", "delete", "delete_all", "report"])
    func operations_propagateErrors(operation: String) async {
        let service = RecordingChatService()
        service.error = ManagerTestError.requested
        let manager = ChatManager(service: service)

        await #expect(throws: ManagerTestError.requested) {
            switch operation {
            case "create": try await manager.createNewChat(chat: makeChat())
            case "add": try await manager.addChatMessage(message: ChatMessage(id: "message_123", chatId: "chat_123"))
            case "load": _ = try await manager.loadChat(userId: "user_123", avatarId: "avatar_456")
            case "load_all": _ = try await manager.loadChats(userId: "user_123")
            case "seen": try await manager.userHasSeenMessage(messageId: "message_123", chatId: "chat_123", userId: "user_123")
            case "delete": try await manager.deleteChat(chatId: "chat_123")
            case "delete_all": try await manager.deleteAllChats(userId: "user_123")
            default: try await manager.reportChat(chatId: "chat_123", userId: "user_123")
            }
        }
        #expect(service.calls.count == 1)
    }

    private func makeChat(id: String = "chat_123") -> Chat {
        Chat(id: id, userId: "user_123", avatarId: "avatar_456", dateCreated: Date(timeIntervalSince1970: 1_700_000_000), dateModified: Date(timeIntervalSince1970: 1_700_000_500))
    }
}

@MainActor
private final class RecordingChatService: ChatService {
    var calls: [String] = []
    var error: Error?
    var streamError: Error?
    var messageBatches: [[ChatMessage]] = []
    var chat: Chat?
    var chats: [Chat] = []
    var createdChat: Chat?
    var addedMessage: ChatMessage?

    private func record(_ call: String) throws {
        calls.append(call)
        if let error { throw error }
    }

    func streamChatMessages(chatId: String) -> AsyncThrowingStream<[ChatMessage], Error> {
        calls.append("stream:\(chatId)")
        return AsyncThrowingStream { continuation in
            for batch in messageBatches { continuation.yield(batch) }
            continuation.finish(throwing: streamError)
        }
    }

    func createNewChat(chat: Chat) async throws { try record("create:\(chat.id)"); createdChat = chat }
    func addChatMessage(message: ChatMessage) async throws { try record("add:\(message.id)"); addedMessage = message }
    func loadChat(userId: String, avatarId: String) async throws -> Chat? { try record("load:\(userId):\(avatarId)"); return chat }
    func loadUsersChats(userId: String) async throws -> [Chat] { try record("load_all:\(userId)"); return chats }
    func userHasSeenMessage(messageId: String, chatId: String, userId: String) async throws { try record("seen:\(messageId):\(chatId):\(userId)") }
    func deleteChat(chatId: String) async throws { try record("delete:\(chatId)") }
    func deleteAllChatsForUser(userId: String) async throws { try record("delete_all:\(userId)") }
    func reportChat(chatId: String?, userId: String) async throws { try record("report:\(chatId ?? "nil"):\(userId)") }
}
