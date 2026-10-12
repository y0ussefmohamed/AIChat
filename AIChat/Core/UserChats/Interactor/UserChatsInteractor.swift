//
//  UserChatsInteractor.swift
//  AIChat
//

import Foundation

@MainActor
protocol UserChatsInteractor {
    var currentUser: UserModel? { get }

    func loadChats(userId: String) async throws -> [Chat]
    func getRecentAvatars() throws -> [Avatar]
    func getAvatar(id: String) async throws -> Avatar
    func streamChatChanges(chatId: String) -> AsyncThrowingStream<[ChatMessage], Error>
    func trackEvent(event: any LoggableEvent)
}
extension CoreInteractor: UserChatsInteractor {}
