//
//  FirebaseUserService.swift
//  AIChat
//
//  Created by Youssef Mohamed on 15/04/2026.
//

import Foundation
import Combine
import SwiftUI
import FirebaseFirestore
import SwiftfulFirestore

struct FirebaseUserService: UserService {
    var collection: CollectionReference = Firestore.firestore().collection("users")

    /// Automatically listens to any change in the document with this usedId
    func streamUser(userId: String) -> AsyncThrowingStream<UserModel, Error> {
        collection.streamDocument(id: userId)
    }

    func saveUser(_ user: UserModel) async throws {
        try collection.document(user.userId).setData(from: user, merge: true)
    }

    func markOnboardingAsCompleted(userId: String, profileColorHex: String) async throws {
        let updates: [String: Any] = [
            UserModel.CodingKeys.didCompleteOnboarding.rawValue: true,
            UserModel.CodingKeys.profileColorHex.rawValue: profileColorHex
        ]

        try await collection.document(userId).updateData(updates)
    }

    func deleteUser(userId: String) async throws {
        try await collection.document(userId).delete()
    }
}
