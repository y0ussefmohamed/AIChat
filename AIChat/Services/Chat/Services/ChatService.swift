//
//  ChatService.swift
//  AIChat
//
//  Created by Youssef Mohamed on 24/04/2026.
//

import Foundation

protocol ChatService: Sendable {
    func createNewChat(chat: Chat) async throws
}
