import Foundation
import UIKit
import Testing
@testable import AIChat

@MainActor
struct AvatarManagerTests {

    @Test("Adding a recent avatar saves locally before incrementing its remote click count")
    func addRecentAvatar_savesBeforeIncrementing() async throws {
        let fixture = makeManager()
        let manager = fixture.manager
        let remote = fixture.remote
        let local = fixture.local
        let avatar = Avatar(avatarId: "avatar_123", name: "Alpha")

        try await manager.addRecentAvatar(avatar)

        #expect(local.addedAvatars == [avatar])
        #expect(remote.calls == ["increment:avatar_123"])
        #expect(local.recorder.calls == ["add_recent:avatar_123", "increment:avatar_123"])
    }

    @Test("A local save failure prevents the remote click-count update")
    func addRecentAvatar_whenLocalSaveFails_stopsBeforeRemote() async {
        let fixture = makeManager()
        let manager = fixture.manager
        let remote = fixture.remote
        let local = fixture.local
        local.error = ManagerTestError.requested

        await #expect(throws: ManagerTestError.requested) {
            try await manager.addRecentAvatar(Avatar(avatarId: "avatar_123"))
        }
        #expect(local.addedAvatars.isEmpty)
        #expect(remote.calls.isEmpty)
        #expect(local.recorder.calls == ["add_recent:avatar_123"])
    }

    @Test("A remote increment failure propagates after the avatar has been saved locally")
    func addRecentAvatar_whenIncrementFails_preservesLocalSave() async {
        let fixture = makeManager()
        let manager = fixture.manager
        let remote = fixture.remote
        let local = fixture.local
        let avatar = Avatar(avatarId: "avatar_123")
        remote.error = ManagerTestError.requested

        await #expect(throws: ManagerTestError.requested) {
            try await manager.addRecentAvatar(avatar)
        }
        #expect(local.addedAvatars == [avatar])
        #expect(local.recorder.calls == ["add_recent:avatar_123", "increment:avatar_123"])
    }

    @Test("Recent avatars are returned from local persistence in the saved order")
    func getRecentAvatars_returnsLocalResults() throws {
        let fixture = makeManager()
        let manager = fixture.manager
        let remote = fixture.remote
        let local = fixture.local
        local.recentAvatars = [Avatar(avatarId: "second"), Avatar(avatarId: "first")]

        #expect(try manager.getRecentAvatars() == local.recentAvatars)
        #expect(local.recorder.calls == ["get_recents"])
        #expect(remote.calls.isEmpty)
    }

    @Test("Loading recent avatars propagates local persistence errors")
    func getRecentAvatars_propagatesError() {
        let fixture = makeManager()
        let manager = fixture.manager
        let remote = fixture.remote
        let local = fixture.local
        local.error = ManagerTestError.requested

        #expect(throws: ManagerTestError.requested) {
            try manager.getRecentAvatars()
        }
        #expect(remote.calls.isEmpty)
    }

    @Test("Creating an avatar forwards the model and the original image")
    func createAvatar_forwardsModelAndImage() async throws {
        let fixture = makeManager()
        let manager = fixture.manager
        let remote = fixture.remote
        let local = fixture.local
        let avatar = Avatar(avatarId: "avatar_123", name: "Alpha")
        let image = UIImage()

        try await manager.createAvatar(avatar: avatar, image: image)

        #expect(remote.createdAvatar == avatar)
        #expect(remote.createdImage === image)
        #expect(remote.calls == ["create:avatar_123"])
        #expect(local.addedAvatars.isEmpty)
    }

    @Test("Getting an avatar forwards its ID and returns the remote model")
    func getAvatar_returnsRemoteResult() async throws {
        let fixture = makeManager()
        let manager = fixture.manager
        let remote = fixture.remote
        remote.avatar = Avatar(avatarId: "requested_avatar", name: "Alpha")

        #expect(try await manager.getAvatar(id: "requested_avatar") == remote.avatar)
        #expect(remote.calls == ["get:requested_avatar"])
    }

    @Test("Avatar list operations route to the matching remote endpoint", arguments: ["featured", "popular", "category", "user"])
    func avatarLists_forwardArgumentsAndPreserveOrder(operation: String) async throws {
        let fixture = makeManager()
        let manager = fixture.manager
        let remote = fixture.remote
        remote.avatars = [Avatar(avatarId: "second"), Avatar(avatarId: "first")]
        let result: [Avatar]
        let expectedCall: String

        switch operation {
        case "featured":
            result = try await manager.getFeaturedAvatars()
            expectedCall = "featured"
        case "popular":
            result = try await manager.getPopularAvatars()
            expectedCall = "popular"
        case "category":
            result = try await manager.getAvatarsByCategory(.alien)
            expectedCall = "category:alien"
        default:
            result = try await manager.getCurrentUserAvatars(userId: "user_123")
            expectedCall = "user:user_123"
        }

        #expect(result == remote.avatars)
        #expect(remote.calls == [expectedCall])
    }

    @Test("An empty avatar list is returned without substituting mock data")
    func getFeaturedAvatars_preservesEmptyList() async throws {
        let fixture = makeManager()
        let manager = fixture.manager
        let remote = fixture.remote
        remote.avatars = []

        #expect(try await manager.getFeaturedAvatars().isEmpty)
    }

    @Test("Deleting an avatar forwards its ID")
    func deleteAvatar_forwardsID() async throws {
        let fixture = makeManager()
        let manager = fixture.manager
        let remote = fixture.remote

        try await manager.deleteAvatar(id: "avatar_123")

        #expect(remote.calls == ["delete:avatar_123"])
    }

    @Test("Removing authorship forwards the deleted user's ID")
    func removeAuthorId_forwardsUserID() async throws {
        let fixture = makeManager()
        let manager = fixture.manager
        let remote = fixture.remote

        try await manager.removeAuthorIdFromTheDeletedUserAvatars(userId: "user_123")

        #expect(remote.calls == ["remove_author:user_123"])
    }

    @Test("Every remote avatar operation propagates service errors", arguments: ["create", "get", "delete", "featured", "popular", "category", "user", "remove_author"])
    func remoteOperations_propagateErrors(operation: String) async {
        let fixture = makeManager()
        let manager = fixture.manager
        let remote = fixture.remote
        let local = fixture.local
        remote.error = ManagerTestError.requested

        await #expect(throws: ManagerTestError.requested) {
            switch operation {
            case "create": try await manager.createAvatar(avatar: Avatar(avatarId: "avatar_123"), image: UIImage())
            case "get": _ = try await manager.getAvatar(id: "avatar_123")
            case "delete": try await manager.deleteAvatar(id: "avatar_123")
            case "featured": _ = try await manager.getFeaturedAvatars()
            case "popular": _ = try await manager.getPopularAvatars()
            case "category": _ = try await manager.getAvatarsByCategory(.alien)
            case "user": _ = try await manager.getCurrentUserAvatars(userId: "user_123")
            default: try await manager.removeAuthorIdFromTheDeletedUserAvatars(userId: "user_123")
            }
        }
        #expect(remote.calls.count == 1)
        #expect(local.addedAvatars.isEmpty)
    }

    private func makeManager() -> AvatarManagerFixture {
        let recorder = AvatarOperationRecorder()
        let remote = RecordingRemoteAvatarService(recorder: recorder)
        let local = RecordingLocalAvatarPersistence(recorder: recorder)
        let manager = AvatarManager(services: MockAvatarServices(remote: remote, local: local))
        return AvatarManagerFixture(manager: manager, remote: remote, local: local)
    }
}

@MainActor
private struct AvatarManagerFixture {
    let manager: AvatarManager
    let remote: RecordingRemoteAvatarService
    let local: RecordingLocalAvatarPersistence
}

@MainActor
private final class AvatarOperationRecorder {
    var calls: [String] = []
}

@MainActor
private final class RecordingRemoteAvatarService: RemoteAvatarService {
    let recorder: AvatarOperationRecorder
    var calls: [String] = []
    var error: Error?
    var avatar = Avatar(avatarId: "avatar_123")
    var avatars: [Avatar] = []
    var createdAvatar: Avatar?
    var createdImage: UIImage?

    init(recorder: AvatarOperationRecorder) { self.recorder = recorder }

    private func record(_ call: String) throws {
        calls.append(call)
        recorder.calls.append(call)
        if let error { throw error }
    }

    func createAvatar(avatar: Avatar, image: UIImage) async throws {
        try record("create:\(avatar.avatarId)")
        createdAvatar = avatar
        createdImage = image
    }

    func getAvatar(id: String) async throws -> Avatar {
        try record("get:\(id)")
        return avatar
    }

    func deleteAvatar(id: String) async throws { try record("delete:\(id)") }
    func getFeaturedAvatars() async throws -> [Avatar] { try record("featured"); return avatars }
    func getPopularAvatars() async throws -> [Avatar] { try record("popular"); return avatars }
    func getAvatarsByCategory(_ category: CharacterOption) async throws -> [Avatar] { try record("category:\(category.rawValue)"); return avatars }
    func getCurrentUserAvatars(userId: String) async throws -> [Avatar] { try record("user:\(userId)"); return avatars }
    func incrementAvatarClickCount(avatarId: String) async throws { try record("increment:\(avatarId)") }
    func removeAuthorIdFromTheDeletedUserAvatars(userId: String) async throws { try record("remove_author:\(userId)") }
}

@MainActor
private final class RecordingLocalAvatarPersistence: LocalAvatarPersistence {
    let recorder: AvatarOperationRecorder
    var addedAvatars: [Avatar] = []
    var recentAvatars: [Avatar] = []
    var error: Error?

    init(recorder: AvatarOperationRecorder) { self.recorder = recorder }

    func addRecentAvatar(avatar: Avatar) throws {
        recorder.calls.append("add_recent:\(avatar.avatarId)")
        if let error { throw error }
        addedAvatars.append(avatar)
    }

    func getRecentAvatars() throws -> [Avatar] {
        recorder.calls.append("get_recents")
        if let error { throw error }
        return recentAvatars
    }
}
