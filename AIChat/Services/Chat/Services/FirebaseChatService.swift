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
    var collection: CollectionReference = Firestore.firestore().collection("chats")

    func createNewChat(chat: Chat) async throws {
        try collection.document(chat.id).setData(from: chat, merge: true)
    }
}
