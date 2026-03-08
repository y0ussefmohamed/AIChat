//
//  ChatMessage.swift
//  AIChat
//
//  Created by Youssef Mohamed on 08/03/2026.
//

import Foundation

struct ChatMessage: Identifiable {
    let id: String
    let chatId: String
    let authorId: String?
    let content: String?
    let seenByIds: [String]?
    let dateCreated: Date?

    init(id: String, chatId: String, authorId: String? = nil, content: String? = nil, seenByIds: [String]? = nil, dateCreated: Date? = nil) {
        self.id = id
        self.chatId = chatId
        self.authorId = authorId
        self.content = content
        self.seenByIds = seenByIds
        self.dateCreated = dateCreated
    }

    static var mock: ChatMessage {
        mocks[0]
    }

    static var mocks: [ChatMessage] {
        let now = Date()

        return [
            ChatMessage(
                id: "msg1",
                chatId: "chat_1",
                authorId: "user_1",
                content: "Hey! How are you?",
                seenByIds: ["user_1"],
                dateCreated: now.addingTimeInterval(minutes: -30)
            ),
            ChatMessage(
                id: "msg2",
                chatId: "chat_1",
                authorId: "user_2",
                content: "I'm good! Working on my AI chat app.",
                seenByIds: ["user_1", "user_2"],
                dateCreated: now.addingTimeInterval(minutes: -25)
            ),
            ChatMessage(
                id: "msg3",
                chatId: "chat_2",
                authorId: "user_3",
                content: "Did you finish the SwiftUI architecture course?",
                seenByIds: ["user_3"],
                dateCreated: now.addingTimeInterval(hours: -2)
            ),
            ChatMessage(
                id: "msg4",
                chatId: "chat_2",
                authorId: "user_4",
                content: "Almost! Just the last module left.",
                seenByIds: ["user_3", "user_4"],
                dateCreated: now.addingTimeInterval(hours: -1, minutes: -10)
            )
        ]
    }
}
