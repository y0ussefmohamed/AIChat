//
//  ChatInteractor.swift
//  AIChat
//  Created by Youssef Mohamed on 12/03/2026.
//

import Foundation

@MainActor
protocol ChatInteractor {
    var currentUser: UserModel? { get }

    func getAuthId() throws -> String
    func trackEvent(event: any LoggableEvent)
    func getAvatar(id: String) async throws -> Avatar
    func addRecentAvatar(_ avatar: Avatar) async throws
    func generateText(input: String) async throws -> String
    func createNewChat(chat: Chat) async throws
    func addChatMessage(message: ChatMessage) async throws
    func loadChat(userId: String, avatarId: String) async throws -> Chat?
    func streamChatChanges(chatId: String) -> AsyncThrowingStream<[ChatMessage], Error>
    func userHasSeenMessage(messageId: String, chatId: String, userId: String) async throws
    func deleteChat(chatId: String) async throws
    func reportChat(chatId: String?, userId: String) async throws
}
extension CoreInteractor: ChatInteractor { }
