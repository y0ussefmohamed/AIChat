//
//  ChatRowCellInteractor.swift
//  AIChat
//

import Foundation

@MainActor
protocol ChatRowCellInteractor {
    var currentUser: UserModel? { get }

    func getAvatar(id: String) async throws -> Avatar
    func streamChatChanges(chatId: String) -> AsyncThrowingStream<[ChatMessage], Error>
    func trackEvent(event: any LoggableEvent)
}
extension CoreInteractor: ChatRowCellInteractor { }
