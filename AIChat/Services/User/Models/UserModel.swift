//
//  UserModel.swift
//  AIChat
//
//  Created by Youssef Mohamed on 10/03/2026.
//

import Foundation
import SwiftUI

/// What will be saved in the `Firestore DB`, it should contain important fields from the `UserAuthInfo` Model and have an init to convert to `self`
struct UserModel: Codable {
    let userId: String
    let email: String?
    let isAnonymous: Bool?
    let creationDate: Date?
    let creationVersion: String?
    let lastSignInDate: Date?
    let didCompleteOnboarding: Bool?
    let profileColorHex: String? /// Hex is used because we can't store a `Color Type` inside Firebase because it is SwiftUI specific

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case email
        case isAnonymous = "is_anonymous"
        case creationDate = "creation_date"
        case creationVersion = "creation_version"
        case lastSignInDate = "last_sign_in_date"
        case didCompleteOnboarding = "did_complete_onboarding"
        case profileColorHex = "profile_color_hex"
    }

    init(
        userId: String,
        email: String? = nil,
        isAnonymous: Bool? = nil,
        creationDate: Date? = nil,
        creationVersion: String? = nil,
        lastSignInDate: Date? = nil,
        didCompleteOnboarding: Bool? = nil,
        profileColorHex: String? = nil
    ) {
        self.userId = userId
        self.email = email
        self.isAnonymous = isAnonymous
        self.creationDate = creationDate
        self.creationVersion = creationVersion
        self.lastSignInDate = lastSignInDate
        self.didCompleteOnboarding = didCompleteOnboarding
        self.profileColorHex = profileColorHex
    }

    init(auth: UserAuthInfo, creationVersion: String?) {
        self.init(
            userId: auth.uid,
            email: auth.email,
            isAnonymous: auth.isAnonymous,
            creationDate: auth.creationDate,
            creationVersion: creationVersion,
            lastSignInDate: auth.lastSignInDate
        )
    }


    var profileColor: Color {
        guard let profileColorHex else { return .accent }

        return Color(hex: profileColorHex)
    }

    static var mock: Self {
        mocks[0]
    }

    static var mocks: [UserModel] {
            let now = Date()

            return [
                UserModel(
                    userId: "user",
                    email: "hello@example.com",
                    creationDate: now.addingTimeInterval(-86400), // 1 day ago
                    didCompleteOnboarding: true,
                    profileColorHex: "#FF6B6B"
                ),
                UserModel(
                    userId: "user2",
                    isAnonymous: true,
                    creationDate: now.addingTimeInterval(-259200), // 3 days ago
                    didCompleteOnboarding: false,
                    profileColorHex: "#4ECDC4"
                ),
                UserModel(
                    userId: "user",
                    email: "dev@swiftui.com",
                    creationDate: now.addingTimeInterval(-432000), // 5 days ago
                    didCompleteOnboarding: true,
                    profileColorHex: "#556270"
                ),
                UserModel(
                    userId: "user2",
                    email: "dev@swiftui.com",
                    creationDate: now.addingTimeInterval(-432000), // 5 days ago
                    didCompleteOnboarding: true,
                    profileColorHex: "#556270"
                )
            ]
    }
}
