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

    func createNewChat(chat: Chat) async throws {
        try await service.createNewChat(chat: chat)
    }
}
