//
//  FirebaseAvatarService.swift
//  AIChat
//
//  Created by Youssef Mohamed on 16/04/2026.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import SwiftfulFirestore

struct FirebaseAvatarService: RemoteAvatarService {
    var collection: CollectionReference = Firestore.firestore().collection("avatars")

    func createAvatar(avatar: Avatar, image: UIImage) async throws {
        let path = "avatars/\(avatar.avatarId)"
        let url = try await FirebaseImageUploadService().uploadImage(image: image, path: path)

        var avatarToSave = avatar
        avatarToSave.updateProfileImage(withName: url.absoluteString) /// avatarProfileImageName is now the url of the stored UIImage

        try collection.document(avatarToSave.avatarId).setData(from: avatarToSave, merge: true)
    }

    func getAvatar(id: String) async throws -> Avatar {
        try await collection.getDocument(id: id)
    }

    func deleteAvatar(id: String) async throws {
        let path = "avatars/\(id)"
        try await FirebaseImageUploadService().deleteImage(path: path)
        
        try await collection.deleteDocument(id: id)
    }

    func getFeaturedAvatars() async throws -> [Avatar] {
        let avatars: [Avatar] = try await collection.limit(to: 50).getAllDocuments()
        return avatars.choose(5)
    }

    func getPopularAvatars() async throws -> [Avatar] {
        try await collection
            .limit(to: 50)
            .getAllDocuments()
            .sorted(by: {($0.clickCount ?? .zero) > ($1.clickCount ?? .zero) })
    }

    func getAvatarsByCategory(_ category: CharacterOption) async throws -> [Avatar] {
        let avatars: [Avatar] = try await collection
            .whereField(Avatar.CodingKeys.characterOption.rawValue, isEqualTo: category.rawValue)
            .getAllDocuments()

        return avatars
    }

    func getCurrentUserAvatars(userId: String) async throws -> [Avatar] {
        try await collection
            .whereField(Avatar.CodingKeys.authorId.rawValue, isEqualTo: userId)
            .getAllDocuments()
            .sorted(by: {($0.dateCreated ?? .distantPast) > ($1.dateCreated ?? .distantPast) })
    }

    func incrementAvatarClickCount(avatarId: String) async throws {
        try await collection.document(avatarId).updateData([Avatar.CodingKeys.clickCount.rawValue: FieldValue.increment(Int64(1))])
    }

    func removeAuthorIdFromTheDeletedUserAvatars(userId: String) async throws {
        let avatars = try await self.getCurrentUserAvatars(userId: userId)

        try await withThrowingTaskGroup(of: Void.self) { group in
            for avatar in avatars {
                group.addTask {
                    try await collection.document(avatar.avatarId).updateData([
                        Avatar.CodingKeys.authorId.rawValue: NSNull()
                    ])
                }
            }
            try await group.waitForAll()
        }
    }
}
