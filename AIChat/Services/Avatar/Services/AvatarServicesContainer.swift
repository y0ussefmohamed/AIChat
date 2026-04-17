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
    let remote: RemoteAvatarService = MockAvatarService()
    let local: LocalAvatarPersistence = MockLocalAvatarPersistence()
}
