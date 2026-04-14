//
//  UserManager.swift
//  AIChat
//
//  Created by Youssef Mohamed on 14/04/2026.
//

import Foundation
import SwiftUI
import SwiftfulUtilities
import FirebaseFirestore

protocol UserService: Sendable {
    func saveUser(_ user: UserModel) async throws

    func deleteUser(userId: String) async throws
}

struct MockUserService: UserService {
    func saveUser(_ user: UserModel) async throws { }

    func deleteUser(userId: String) async throws  { }
}

struct FirebaseUserService: UserService {
    var collection: CollectionReference = Firestore.firestore().collection("users")

    func saveUser(_ user: UserModel) async throws {
        try collection.document(user.userId).setData(from: user, merge: true)
    }

    func deleteUser(userId: String) async throws {
        try await collection.document(userId).delete()
    }
}



@MainActor
@Observable
class UserManager {
    private let service: UserService
    private(set) var currentUser: UserModel?

    init(service: UserService) {
        self.service = service
        self.currentUser = nil
    }

    func logIn(auth: UserAuthInfo, isNewUser: Bool) async throws {
        let creationVersion = isNewUser ? Utilities.appVersion : nil
        let user = UserModel(auth: auth, creationVersion: creationVersion)

        try await service.saveUser(user)
    }

    func deleteUser(auth: UserAuthInfo) async throws {
        try await service.deleteUser(userId: auth.uid)
    }
}
