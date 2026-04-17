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

        var avatar = avatar
        avatar.updateProfileImage(withName: url.absoluteString) /// avatarProfileImageName is now the url of the stored UIImage

        try collection.document(avatar.avatarId).setData(from: avatar, merge: true)
    }

    func getAvatar(id: String) async throws -> Avatar {
        try await collection.getDocument(id: id)
    }

    func getFeaturedAvatars() async throws -> [Avatar] {
        let avatars: [Avatar] = try await collection.limit(to: 50).getAllDocuments()
        return avatars.choose(5)
    }

    func getPopularAvatars() async throws -> [Avatar] {
        let avatars: [Avatar] = try await collection.limit(to: 200).getAllDocuments()
        return avatars
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
    }
}
