//
//  Chat.swift
//  AIChat
//
//  Created by Youssef Mohamed on 08/03/2026.
//

import Foundation

struct Chat: Identifiable {
    let id: String
    let userId: String
    let avatarId: String
    let dateCreated: Date
    let dateModified: Date
    // let messages: [ChatMessage]

    static var mock: Chat {
        mocks[0]
    }

    static var mocks: [Chat] {
        let now = Date()

        return [
            Chat(
                id: "mock_chat_1",
                userId: "user_1",
                avatarId: "avatar_swift",
                dateCreated: now.addingTimeInterval(hours: -1),
                dateModified: now.addingTimeInterval(minutes: -30)
            ),
            Chat(
                id: "mock_chat_2",
                userId: "user_2",
                avatarId: "avatar_ai",
                dateCreated: now.addingTimeInterval(hours: -3),
                dateModified: now.addingTimeInterval(hours: -2)
            ),
            Chat(
                id: "mock_chat_3",
                userId: "user_3",
                avatarId: "avatar_fitness",
                dateCreated: now.addingTimeInterval(days: -1),
                dateModified: now.addingTimeInterval(hours: -5)
            ),
            Chat(
                id: "mock_chat_4",
                userId: "user_4",
                avatarId: "avatar_trainer",
                dateCreated: now.addingTimeInterval(days: -2),
                dateModified: now.addingTimeInterval(days: -1, hours: -3)
            )
        ]
    }
}
