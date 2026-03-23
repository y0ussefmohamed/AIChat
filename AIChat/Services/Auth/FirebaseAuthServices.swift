//
//  FirebaseAuthServices.swift
//  AIChat
//
//  Created by Youssef Mohamed on 23/03/2026.
//

import Foundation
import FirebaseAuth
import SwiftUI

extension EnvironmentValues {
    @Entry /// to use `\.authService` as a `Keypath` in the `@Environment`
    var authServices: FirebaseAuthServices = FirebaseAuthServices()
    /// this class will be created at the start of the app and will always be in the `@Environment`
}

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

    init(user: User) {
        self.uid = user.uid
        self.email = user.email
        self.isAnonymous = user.isAnonymous
        self.creationDate = user.metadata.creationDate
        self.lastSignInDate = user.metadata.lastSignInDate
    }
}

struct FirebaseAuthServices {

    func getAuthenticatedUser() -> UserAuthInfo? {
        if let user = Auth.auth().currentUser {
            return UserAuthInfo(user: user)
        }

        return nil
    }

    func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        let authData = try await Auth.auth().signInAnonymously()

        let user = UserAuthInfo(user: authData.user)
        let isNewUser = authData.additionalUserInfo?.isNewUser ?? true

        return (user, isNewUser)
    }
}
