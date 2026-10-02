#if MOCK
import Foundation

@MainActor
final class UITestChatService: ChatService {
    private struct Subscription {
        let chatId: String
        let continuation: AsyncThrowingStream<[ChatMessage], Error>.Continuation
    }

    private let scenario: UITestScenario
    private var chats: [Chat] = []
    private var messages: [ChatMessage] = []
    private var subscriptions: [UUID: Subscription] = [:]

    init(scenario: UITestScenario) {
        self.scenario = scenario
        guard scenario != .emptyChats && scenario != .emptyConversation else { return }
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        chats = [
            Chat(id: UITestFixture.alphaChatId, userId: UITestFixture.userId, avatarId: "alpha", dateCreated: date, dateModified: date.addingTimeInterval(60)),
            Chat(id: UITestFixture.betaChatId, userId: UITestFixture.userId, avatarId: "beta", dateCreated: date, dateModified: date)
        ]
        messages = [
            ChatMessage(id: UITestFixture.previousUserMessageId, chatId: UITestFixture.alphaChatId, authorId: UITestFixture.userId, content: UITestFixture.previousUserMessage, seenByIds: [UITestFixture.userId], dateCreated: date),
            ChatMessage(id: UITestFixture.greetingId, chatId: UITestFixture.alphaChatId, authorId: "alpha", content: UITestFixture.greeting, seenByIds: [], dateCreated: date.addingTimeInterval(60)),
            ChatMessage(id: "beta-greeting", chatId: UITestFixture.betaChatId, authorId: "beta", content: UITestFixture.betaGreeting, seenByIds: [UITestFixture.userId], dateCreated: date)
        ]
    }

    func streamChatMessages(chatId: String) -> AsyncThrowingStream<[ChatMessage], Error> {
        let id = UUID()
        return AsyncThrowingStream { continuation in
            if scenario == .messageStreamFailure {
                continuation.finish(throwing: UITestFailure.requested)
                return
            }
            subscriptions[id] = Subscription(chatId: chatId, continuation: continuation)
            continuation.yield(snapshot(chatId: chatId))
            continuation.onTermination = { [weak self] _ in
                Task { @MainActor in self?.subscriptions.removeValue(forKey: id) }
            }
        }
    }

    private func snapshot(chatId: String) -> [ChatMessage] {
        messages.filter { $0.chatId == chatId }.sorted { $0.dateCreatedCalculated < $1.dateCreatedCalculated }
    }

    private func publish(chatId: String) {
        let value = snapshot(chatId: chatId)
        for subscription in subscriptions.values where subscription.chatId == chatId {
            subscription.continuation.yield(value)
        }
    }

    func createNewChat(chat: Chat) async throws {
        chats.removeAll { $0.id == chat.id }
        chats.append(chat)
    }

    func addChatMessage(message: ChatMessage) async throws {
        if scenario == .sendFailure { throw UITestFailure.requested }
        messages.append(message)
        publish(chatId: message.chatId)
    }

    func loadChat(userId: String, avatarId: String) async throws -> Chat? {
        chats.first { $0.userId == userId && $0.avatarId == avatarId }
    }

    func loadUsersChats(userId: String) async throws -> [Chat] {
        chats.filter { $0.userId == userId }
    }

    func userHasSeenMessage(messageId: String, chatId: String, userId: String) async throws {
        guard let index = messages.firstIndex(where: { $0.id == messageId }), !messages[index].isSeenBy(userId: userId) else { return }
        let message = messages[index]
        messages[index] = ChatMessage(id: message.id, chatId: chatId, authorId: message.authorId, content: message.content, seenByIds: (message.seenByIds ?? []) + [userId], dateCreated: message.dateCreated)
        publish(chatId: chatId)
    }

    func deleteChat(chatId: String) async throws {
        if scenario == .deleteChatFailure { throw UITestFailure.requested }
        chats.removeAll { $0.id == chatId }
        messages.removeAll { $0.chatId == chatId }
        publish(chatId: chatId)
    }

    func deleteAllChatsForUser(userId: String) async throws {
        let ids = chats.filter { $0.userId == userId }.map(\.id)
        for id in ids { try await deleteChat(chatId: id) }
    }

    func reportChat(chatId: String?, userId: String) async throws {
        if scenario == .reportFailure { throw UITestFailure.requested }
    }
}
#endif
