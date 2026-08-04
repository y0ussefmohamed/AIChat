//
//  UserAuthInfo.swift
//  AIChat
//
//  Created by Youssef Mohamed on 24/03/2026.
//

import Foundation
import SwiftUI

struct UserAuthInfo: Sendable, Codable {
    let uid: String
    let email: String?
    let isAnonymous: Bool
    let creationDate: Date?
    let lastSignInDate: Date?

    enum CodingKeys: String, CodingKey {
        case uid
        case email
        case isAnonymous = "is_anonymous"
        case creationDate = "creation_date"
        case lastSignInDate = "last_sign_in_date"
    }

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

    var eventParameters: [String: Any] {
        let dict: [String: Any?] = [
            "uauth_\(CodingKeys.uid.rawValue)": uid,
            "uauth_\(CodingKeys.email.rawValue)": email,
            "uauth_\(CodingKeys.isAnonymous.rawValue)": isAnonymous,
            "uauth_\(CodingKeys.creationDate.rawValue)": creationDate,
            "uauth_\(CodingKeys.lastSignInDate.rawValue)": lastSignInDate
        ]

        return dict.compactMapValues { $0 }
    }
}
