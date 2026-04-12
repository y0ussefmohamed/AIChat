//
//  UserAuthInfo.swift
//  AIChat
//
//  Created by Youssef Mohamed on 24/03/2026.
//

import Foundation
import SwiftUI

struct UserAuthInfo: Sendable {
    let uid: String
    let email: String?
    let isAnonymous: Bool
    let creationDate: Date?
    let lastSignInDate: Date?

    init (uid: String, email: String? = nil, isAnonymous: Bool = false, creationDate: Date? = nil, lastSignInDate: Date? = nil) {
        self.uid = uid
        self.email = email
        self.isAnonymous = isAnonymous
        self.creationDate = creationDate
        self.lastSignInDate = lastSignInDate
    }

    static func mock(isAnonymous: Bool = false) -> Self {
        UserAuthInfo(
            uid: "user_12345",
            email: "hello@gemini.ai",
            isAnonymous: isAnonymous,
            creationDate: Date().addingTimeInterval(-86400 * 30), // 30 days ago
            lastSignInDate: Date()
        )
    }
}
