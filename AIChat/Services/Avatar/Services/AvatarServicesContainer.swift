//
//  AvatarServicesContainer.swift
//  AIChat
//
//  Created by Youssef Mohamed on 17/04/2026.
//

import Foundation

protocol AvatarServicesContainer {
    var remote: RemoteAvatarService { get }
    var local: LocalAvatarPersistence { get }
}

struct ProductionAvatarServices: AvatarServicesContainer {
    let remote: RemoteAvatarService = FirebaseAvatarService()
    let local: LocalAvatarPersistence = SwiftDataLocalAvatarPersistence()
}

struct MockAvatarServices: AvatarServicesContainer {
    let remote: RemoteAvatarService
    let local: LocalAvatarPersistence

    init(remote: RemoteAvatarService = MockAvatarService(), local: LocalAvatarPersistence = MockLocalAvatarPersistence()) {
        self.remote = remote
        self.local = local
    }
}
