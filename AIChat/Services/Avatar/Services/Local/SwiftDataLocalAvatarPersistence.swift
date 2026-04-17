//
// SwiftDataLocalAvatarPersistence.swift
//  AIChat
//
//  Created by Youssef Mohamed on 17/04/2026.
//

import Foundation
import SwiftUI
import SwiftData

@MainActor
struct SwiftDataLocalAvatarPersistence: LocalAvatarPersistence {
    private let container: ModelContainer
    private var mainContext: ModelContext {
        container.mainContext
    }

    init() {
        self.container = try! ModelContainer(for: AvatarEntity.self) // swiftlint:disable:this force_try
    }

    func addRecentAvatar(avatar: Avatar) throws {
        let entity = AvatarEntity(from: avatar)
        mainContext.insert(entity)
        try mainContext.save()
    }

    func getRecentAvatars() throws -> [Avatar] {
        let sortDescriptor = FetchDescriptor<AvatarEntity>(sortBy: [SortDescriptor(\.dateAddedToRecents, order: .reverse)])
        let entities = try mainContext.fetch(sortDescriptor)

        return entities.map({$0.toModel()})
    }
}
