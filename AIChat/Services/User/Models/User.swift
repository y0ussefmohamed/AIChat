//
//  User.swift
//  AIChat
//
//  Created by Youssef Mohamed on 10/03/2026.
//

import Foundation
import SwiftUI

struct User {
    let userId: String
    let dateCreated: Date?
    let didCompleteOnboarding: Bool?
    let profileColorHex: String? /// Hex is used because we can't store a `Color Type` inside Firebase because it is SwiftUI specific

    init(userId: String, dateCreated: Date? = nil, didCompleteOnboarding: Bool? = nil, profileColorHex: String? = nil) {
        self.userId = userId
        self.dateCreated = dateCreated
        self.didCompleteOnboarding = didCompleteOnboarding
        self.profileColorHex = profileColorHex
    }

    var profileColor: Color {
        guard let profileColorHex else { return .accent }

        return Color(hex: profileColorHex)
    }

    static var mock: Self {
        mocks[1]
    }

    static var mocks: [Self] {
        let now = Date()

        return [
            User(
                userId: "user_001",
                dateCreated: now.addingTimeInterval(days: -1),
                didCompleteOnboarding: true,
                profileColorHex: "#FF6B6B"
            ),
            User(
                userId: "user_002",
                dateCreated: now.addingTimeInterval(
                    days: -3,
                    hours: -2
                ),
                didCompleteOnboarding: false,
                profileColorHex: "#4ECDC4"
            ),
            User(
                userId: "user_003",
                dateCreated: now.addingTimeInterval(
                    days: -5,
                    hours: -4
                ),
                didCompleteOnboarding: true,
                profileColorHex: "#556270"
            ),
            User(
                userId: "user_004",
                dateCreated: nil,
                didCompleteOnboarding: nil,
                profileColorHex: nil
            )
        ]
    }
}
