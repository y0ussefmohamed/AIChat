//
//  ChatService.swift
//  AIChat
//
//  Created by Youssef Mohamed on 24/04/2026.
//

import Foundation

protocol ChatService: Sendable {
    func streamChatMessages(chatId: String) -> AsyncThrowingStream<[ChatMessage], Error>
    func createNewChat(chat: Chat) async throws
    func addChatMessage(message: ChatMessage) async throws
    func loadChat(userId: String, avatarId: String) async throws -> Chat?
    func loadUsersChats(userId: String) async throws -> [Chat]
    func userHasSeenMessage(messageId: String, chatId: String, userId: String) async throws
    func deleteChat(chatId: String) async throws
    func deleteAllChatsForUser(userId: String) async throws
}
