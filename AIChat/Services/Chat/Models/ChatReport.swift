//
//  ChatReport.swift
//  AIChat
//
//  Created by Youssef Mohamed on 02/09/2026.
//


//
//  ChatReport.swift
//  AIChat
//

import Foundation

struct ChatReport: Codable {
    let id: String
    let chatId: String
    let userId: String
    let dateCreated: Date

    init(id: String = UUID().uuidString, chatId: String, userId: String, dateCreated: Date = .now) {
        self.id = id
        self.chatId = chatId
        self.userId = userId
        self.dateCreated = dateCreated
    }

    enum CodingKeys: String, CodingKey {
        case id
        case chatId = "chat_id"
        case userId = "user_id"
        case dateCreated = "date_created"
    }
}