//
//  Chat.swift
//  AIChat
//
//  Created by Youssef Mohamed on 08/03/2026.
//

import Foundation

struct Chat: Identifiable, Codable {
    let id: String
    let userId: String
    let avatarId: String
    let dateCreated: Date
    let dateModified: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case avatarId = "avatar_id"
        case dateCreated = "date_created"
        case dateModified = "date_modified"
    }

    static func newChat(userId: String, avatarId: String) -> Self {
        .init(
            id: "\(userId)_\(avatarId)",
            userId: userId,
            avatarId: avatarId,
            dateCreated: .now,
            dateModified: .now,
        )
    }

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
                dateModified: now.addingTimeInterval(minutes: -30),
                // messages: []
            ),
            Chat(
                id: "mock_chat_2",
                userId: "user_2",
                avatarId: "avatar_ai",
                dateCreated: now.addingTimeInterval(hours: -3),
                dateModified: now.addingTimeInterval(hours: -2),
                // messages: []
            ),
            Chat(
                id: "mock_chat_3",
                userId: "user_3",
                avatarId: "avatar_fitness",
                dateCreated: now.addingTimeInterval(days: -1),
                dateModified: now.addingTimeInterval(hours: -5),
                // messages: []
            ),
            Chat(
                id: "mock_chat_4",
                userId: "user_4",
                avatarId: "avatar_trainer",
                dateCreated: now.addingTimeInterval(days: -2),
                dateModified: now.addingTimeInterval(days: -1, hours: -3),
                // messages: []
            )
        ]
    }
}
