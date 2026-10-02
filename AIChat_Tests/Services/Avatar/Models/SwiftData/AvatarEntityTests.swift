import Foundation
import SwiftData
import Testing
@testable import AIChat

@MainActor
struct AvatarEntityTests {

    @Test("Initializing an entity copies every avatar field and records when it was added to recents")
    func init_fromAvatar_mapsPropertiesCorrectly() {
        let avatar = makeAvatar()
        let before = Date()
        let entity = AvatarEntity(from: avatar)
        let after = Date()

        #expect(entity.avatarId == avatar.avatarId)
        #expect(entity.name == avatar.name)
        #expect(entity.characterOption == avatar.characterOption)
        #expect(entity.characterAction == avatar.characterAction)
        #expect(entity.characterLocation == avatar.characterLocation)
        #expect(entity.profileImageName == avatar.profileImageName)
        #expect(entity.authorId == avatar.authorId)
        #expect(entity.dateCreated == avatar.dateCreated)
        #expect(entity.clickCount == avatar.clickCount)
        #expect(entity.dateAddedToRecents >= before)
        #expect(entity.dateAddedToRecents <= after)
    }

    @Test("Converting an entity back to a model preserves all avatar values")
    func toModel_preservesAllProperties() {
        let original = makeAvatar()
        let entity = AvatarEntity(from: original)

        #expect(entity.toModel() == original)
    }

    @Test("Entity conversion preserves missing optional fields")
    func conversion_withMinimalAvatar_preservesNilFields() {
        let avatar = Avatar(avatarId: "minimal")
        let entity = AvatarEntity(from: avatar)

        #expect(entity.name == nil)
        #expect(entity.characterOption == nil)
        #expect(entity.characterAction == nil)
        #expect(entity.characterLocation == nil)
        #expect(entity.profileImageName == nil)
        #expect(entity.authorId == nil)
        #expect(entity.dateCreated == nil)
        #expect(entity.clickCount == nil)
        #expect(entity.toModel() == avatar)
    }

    @Test("Converting after edits reflects current entity values")
    func toModel_afterMutation_mapsUpdatedProperties() {
        let original = makeAvatar()
        let entity = AvatarEntity(from: original)
        let updatedDate = Date(timeIntervalSince1970: 1_700_001_000)
        entity.avatarId = "updated_avatar"
        entity.name = "Beta"
        entity.characterOption = .dog
        entity.characterAction = .walking
        entity.characterLocation = .forest
        entity.profileImageName = "updated.png"
        entity.authorId = "updated_author"
        entity.dateCreated = updatedDate
        entity.clickCount = 12
        entity.dateAddedToRecents = .distantPast

        let expected = Avatar(
            avatarId: "updated_avatar", name: "Beta", characterOption: .dog,
            characterAction: .walking, characterLocation: .forest, profileImageName: "updated.png",
            authorId: "updated_author", dateCreated: updatedDate, clickCount: 12
        )
        #expect(entity.toModel() == expected)
        #expect(original.avatarId == "avatar_123")
        #expect(original.name == "Alpha")
    }

    @Test("Avatar entities preserve model fields and the recents date in an in-memory SwiftData store")
    func persistence_savesAndFetchesEntity() throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: AvatarEntity.self, configurations: configuration)
        let context = ModelContext(container)
        let avatar = makeAvatar()
        let entity = AvatarEntity(from: avatar)
        let recentsDate = Date(timeIntervalSince1970: 1_700_002_000)
        entity.dateAddedToRecents = recentsDate
        context.insert(entity)
        try context.save()

        let fetchContext = ModelContext(container)
        let fetched = try fetchContext.fetch(FetchDescriptor<AvatarEntity>())
        #expect(fetched.count == 1)
        let saved = try #require(fetched.first)
        #expect(saved.toModel() == avatar)
        #expect(saved.dateAddedToRecents == recentsDate)
    }

    private func makeAvatar() -> Avatar {
        Avatar(
            avatarId: "avatar_123", name: "Alpha", characterOption: .alien,
            characterAction: .smiling, characterLocation: .park, profileImageName: "avatar.png",
            authorId: "user_123", dateCreated: Date(timeIntervalSince1970: 1_700_000_000), clickCount: 0
        )
    }
}
