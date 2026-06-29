//
//  UserServices.swift
//  AIChat
//
//  Created by Youssef Mohamed on 15/04/2026.
//

import Foundation

/// Used when a `Manager Class` needs two services to `Inject init`
protocol UserServicesContainer {
    var remote: RemoteUserService { get }
    var local: LocalUserPersistence { get }
}

struct MockUserServicesContainer: UserServicesContainer {
    let remote: RemoteUserService
    let local: LocalUserPersistence

    /// Using this `init` in MockContainer because some views I want to see when `user = nil` or `user = .mock`
    init(user: UserModel? = nil) {
        self.remote = MockUserService(user: user)
        self.local = MockUserPersistence(currentUser: user)
    }
}


struct ProductionUserServicesContainer: UserServicesContainer {
    let remote: RemoteUserService = FirebaseUserService()
    let local: LocalUserPersistence = FileManagerUserPersistence()
}
