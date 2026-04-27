//
//  FirebaseChatService.swift
//  AIChat
//
//  Created by Youssef Mohamed on 24/04/2026.
//

import Foundation
import FirebaseFirestore
import SwiftfulFirestore

struct FirebaseChatService: ChatService {
    private var chatCollection: CollectionReference = Firestore.firestore().collection("chats")

    private func messagesCollection(chatId: String) -> CollectionReference {
        chatCollection.document(chatId).collection("messages")
    }

    func streamChatMessages(chatId: String) -> AsyncThrowingStream<[ChatMessage], Error> {
        messagesCollection(chatId: chatId).streamAllDocuments()
    }

    func userHasSeenMessage(messageId: String, chatId: String, userId: String) async throws {
        try await messagesCollection(chatId: chatId).document(messageId).updateData([
            ChatMessage.CodingKeys.seenByIds.rawValue: FieldValue.arrayUnion([userId])
        ])
    }

    func addChatMessage(message: ChatMessage) async throws {
        // Add Chat Message
        try messagesCollection(chatId: message.chatId).document(message.id).setData(from: message, merge: true)

        // Update the dateModified
        try await chatCollection.document(message.chatId).updateData([
            Chat.CodingKeys.dateModified.rawValue: Date.now
        ])
    }

    func createNewChat(chat: Chat) async throws {
        try chatCollection.document(chat.id).setData(from: chat, merge: true)
    }

    func loadChat(userId: String, avatarId: String) async throws -> Chat? {
        let result: [Chat] = try await chatCollection
            .whereField(Chat.CodingKeys.userId.rawValue, isEqualTo: userId)
            .whereField(Chat.CodingKeys.avatarId.rawValue, isEqualTo: avatarId)
            .getAllDocuments()

        return result.first
    }

    func loadUsersChats(userId: String) async throws -> [Chat] {
        try await chatCollection.whereField(Chat.CodingKeys.userId.rawValue, isEqualTo: userId).getAllDocuments()
    }
}
