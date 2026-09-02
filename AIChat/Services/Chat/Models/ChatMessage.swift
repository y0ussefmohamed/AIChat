//
//  ChatMessage.swift
//  AIChat
//
//  Created by Youssef Mohamed on 08/03/2026.
//

import Foundation

struct ChatMessage: Identifiable, Codable {
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

    enum CodingKeys: String, CodingKey {
        case id
        case chatId = "chat_id"
        case authorId = "author_id"
        case content
        case seenByIds = "seen_by_ids"
        case dateCreated = "date_created"
    }

    var asEventParameter: [String: Any] {
        let dict: [String: Any?] = [
            "chatMessage_\(CodingKeys.id.rawValue)": id,
            "chatMessage_\(CodingKeys.chatId.rawValue)": chatId,
            "chatMessage_\(CodingKeys.authorId.rawValue)": authorId,
            "chatMessage_\(CodingKeys.content.rawValue)": content,
            "chatMessage_\(CodingKeys.seenByIds.rawValue)": seenByIds,
            "chatMessage_\(CodingKeys.dateCreated.rawValue)": dateCreated
        ]

        return dict.compactMapValues({$0})
    }

    var dateCreatedCalculated: Date {
        dateCreated ?? .distantPast
    }

    func isSeenBy(userId: String) -> Bool {
        guard let seenByIds else { return false }
        return seenByIds.contains(userId)
    }

    static func newMessageFromUser(chatId: String, userId: String, message: String, dateCreated: Date? = .now) -> Self {
        .init(
            id: UUID().uuidString,
            chatId: chatId,
            authorId: userId,
            content: message,
            seenByIds: [userId],
            dateCreated: dateCreated
        )
    }

    static func newMessageFromAvatar(chatId: String, avatarId: String, message: String, seenByIds: [String] = [], dateCreated: Date? = .now) -> Self {
        .init(
            id: UUID().uuidString,
            chatId: chatId,
            authorId: avatarId,
            content: message,
            seenByIds: seenByIds,
            dateCreated: dateCreated
        )
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
                authorId: "user",
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
                authorId: "user",
                content: "Did you finish the SwiftUI architecture course?",
                seenByIds: ["user_3"],
                dateCreated: now.addingTimeInterval(hours: -2)
            ),
            ChatMessage(
                id: "msg4",
                chatId: "chat_2",
                authorId: "avt1",
                content: "Almost! Just the last module left.",
                seenByIds: ["user_3", "user_4"],
                dateCreated: now.addingTimeInterval(hours: -1, minutes: -10)
            )
        ]
    }

    static func previewLongConversation(
        chatId: String = Chat.mock.id,
        userId: String = UserModel.mock.userId,
        avatarId: String = Avatar.mock.avatarId
    ) -> [ChatMessage] {
        [
            .newMessageFromAvatar(
                chatId: chatId,
                avatarId: avatarId,
                message: "Hey, what are you working on today?",
                seenByIds: [userId]
            ),
            .newMessageFromUser(
                chatId: chatId,
                userId: userId,
                message: "I am improving the chat screen previews."
            ),
            .newMessageFromAvatar(
                chatId: chatId,
                avatarId: avatarId,
                message: "Nice. Are you testing empty, loading, and long conversations?"
            ),
            .newMessageFromUser(
                chatId: chatId,
                userId: userId,
                message: "Yes, I want one preview with more than six messages."
            ),
            .newMessageFromAvatar(
                chatId: chatId,
                avatarId: avatarId,
                message: "That is useful because it shows scrolling, spacing, timestamps, and bubble alignment."
            ),
            .newMessageFromUser(
                chatId: chatId,
                userId: userId,
                message: "Exactly. I also want to see how long text wraps inside the bubble."
            ),
            .newMessageFromAvatar(
                chatId: chatId,
                avatarId: avatarId,
                message: "Then add a slightly longer message to make sure the design still feels clean on smaller screens."
            ),
            .newMessageFromUser(
                chatId: chatId,
                userId: userId,
                message: "Perfect. This preview should help me polish the UI faster."
            )
        ]
    }
}
