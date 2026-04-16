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

struct FirebaseAvatarService: AvatarService {
    var collection: CollectionReference = Firestore.firestore().collection("avatars")

    func createAvatar(avatar: Avatar, image: UIImage) async throws {
        let path = "avatars/\(avatar.avatarId)"
        let url = try await FirebaseImageUploadService().uploadImage(image: image, path: path)

        var avatar = avatar
        avatar.updateProfileImage(withName: url.absoluteString) /// avatarProfileImageName is now the url of the stored UIImage

        try collection.document(avatar.avatarId).setData(from: avatar, merge: true)
    }
}


