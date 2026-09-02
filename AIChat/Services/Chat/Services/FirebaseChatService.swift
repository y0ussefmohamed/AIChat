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
    private var reportsCollection: CollectionReference = Firestore.firestore().collection("reports")

    private func messagesCollection(chatId: String) -> CollectionReference {
        chatCollection.document(chatId).collection("messages")
    }

    func reportChat(chatId: String?, userId: String) async throws {
        guard let chatId, chatId.isEmpty else { return }
        
        let report = ChatReport(chatId: chatId, userId: userId)
        try reportsCollection.document(report.id).setData(from: report)
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

    func deleteChat(chatId: String) async throws {
        async let deleteChat: () =  chatCollection.deleteDocument(id: chatId)
        async let deleteMessages: () = messagesCollection(chatId: chatId).deleteAllDocuments()

        let (_, _) = await (try deleteChat, try deleteMessages)
    }

    func deleteAllChatsForUser(userId: String) async throws {
        let allChats = try await self.loadUsersChats(userId: userId)

        try await withThrowingTaskGroup(of: Void.self) { group in
            for chat in allChats {
                group.addTask {
                    try await self.deleteChat(chatId: chat.id)
                }
            }

            try await group.waitForAll()
        }
    }
}
