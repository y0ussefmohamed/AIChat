//
//  UserAuthInfo+Firebase.swift
//  AIChat
//
//  Created by Youssef Mohamed on 24/03/2026.
//

import Foundation
import FirebaseAuth

extension UserAuthInfo {
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
        self.isAnonymous = user.isAnonymous
        self.creationDate = user.metadata.creationDate
        self.lastSignInDate = user.metadata.lastSignInDate
    }
}
