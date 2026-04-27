//
//  ChatManager.swift
//  AIChat
//
//  Created by Youssef Mohamed on 24/04/2026.
//

import Foundation

@MainActor
@Observable
class ChatManager {
    let service: ChatService

    init(service: ChatService) {
        self.service = service
    }

    func streamChatChanges(chatId: String) -> AsyncThrowingStream<[ChatMessage], Error> {
        service.streamChatMessages(chatId: chatId)
    }

    func createNewChat(chat: Chat) async throws {
        try await service.createNewChat(chat: chat)
    }

    func addChatMessage(message: ChatMessage) async throws {
        try await service.addChatMessage(message: message)
    }

    func loadChat(userId: String, avatarId: String) async throws -> Chat? {
        try await service.loadChat(userId: userId, avatarId: avatarId)
    }

    func loadChats(userId: String) async throws -> [Chat] {
        try await service.loadUsersChats(userId: userId)
    }

    func userHasSeenMessage(messageId: String, chatId: String, userId: String) async throws {
        try await service.userHasSeenMessage(messageId: messageId, chatId: chatId, userId: userId)
    }

    func deleteChat(chatId: String) async throws {
        try await service.deleteChat(chatId: chatId)
    }

    func deleteAllChats(userId: String) async throws {
        try await service.deleteAllChatsForUser(userId: userId)
    }
}
