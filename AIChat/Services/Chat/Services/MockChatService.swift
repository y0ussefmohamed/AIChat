//
//  MockChatService.swift
//  AIChat
//
//  Created by Youssef Mohamed on 24/04/2026.
//

import Foundation

final class MockChatService: ChatService {

    private let delay: TimeInterval
    private var chat: Chat?
    private var chats: [Chat]
    private var messages: [ChatMessage]

    init(
        delay: TimeInterval = 0,
        chat: Chat? = .mock,
        chats: [Chat] = Chat.mocks,
        messages: [ChatMessage] = ChatMessage.mocks
    ) {
        self.delay = delay
        self.chat = chat
        self.chats = chats
        self.messages = messages
    }

    func streamChatMessages(chatId: String) -> AsyncThrowingStream<[ChatMessage], Error> {
        AsyncThrowingStream { continuation in
            Task {
                await waitIfNeeded()

                let filteredMessages = messages
                    .filter { $0.chatId == chatId }
                    .sorted { $0.dateCreatedCalculated < $1.dateCreatedCalculated }

                continuation.yield(filteredMessages)
                continuation.finish()
            }
        }
    }

    func createNewChat(chat: Chat) async throws {
        await waitIfNeeded()
        self.chat = chat
        chats.append(chat)
    }

    func addChatMessage(message: ChatMessage) async throws {
        await waitIfNeeded()
        messages.append(message)
    }

    func userHasSeenMessage(
        messageId: String,
        chatId: String,
        userId: String
    ) async throws {
        await waitIfNeeded()
    }

    func loadChat(userId: String, avatarId: String) async throws -> Chat? {
        await waitIfNeeded()
        return chat
    }

    func loadUsersChats(userId: String) async throws -> [Chat] {
        await waitIfNeeded()
        return chats
    }

    func deleteChat(chatId: String) async throws {
        await waitIfNeeded()

        chats.removeAll { $0.id == chatId }

        if chat?.id == chatId {
            chat = nil
        }

        messages.removeAll { $0.chatId == chatId }
    }

    func deleteAllChatsForUser(userId: String) async throws {
        await waitIfNeeded()

        chats.removeAll()
        messages.removeAll()
        chat = nil
    }

    private func waitIfNeeded() async {
        guard delay > 0 else { return }
        try? await Task.sleep(for: .seconds(delay))
    }
}
