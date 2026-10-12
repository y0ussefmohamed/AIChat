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
    func trackEvent(event: any LoggableEvent)
}
extension CoreInteractor: UserChatsInteractor {}
