//
//  MockChatService.swift
//  AIChat
//
//  Created by Youssef Mohamed on 24/04/2026.
//

import Foundation

struct MockChatService: ChatService {
    func streamChatMessages(chatId: String) -> AsyncThrowingStream<[ChatMessage], Error> {
        AsyncThrowingStream { continuation in
            continuation.yield([])
            continuation.finish()
        }
    }
    func createNewChat(chat: Chat) async throws {}
    func addChatMessage(message: ChatMessage) async throws {}
    func userHasSeenMessage(messageId: String, chatId: String, userId: String) async throws { }
    func loadChat(userId: String, avatarId: String) async throws -> Chat? { Chat.mock }
    func loadUsersChats(userId: String) async throws -> [Chat] { Chat.mocks }

    func deleteChat(chatId: String) async throws { }

    func deleteAllChatsForUser(userId: String) async throws { }
}
