#if MOCK
import Foundation
import UIKit

@MainActor
final class UITestAvatarService: RemoteAvatarService {
    private var avatars: [Avatar]
    private let scenario: UITestScenario

    init(avatars: [Avatar], scenario: UITestScenario) {
        self.avatars = avatars
        self.scenario = scenario
    }

    func createAvatar(avatar: Avatar, image: UIImage) async throws {
        if scenario == .slowAvatarSave { try await Task.sleep(for: .seconds(2)) }
        if scenario == .avatarSaveFailure { throw UITestFailure.requested }
        var saved = avatar
        saved.updateProfileImage(withName: avatars.first?.profileImageName ?? "")
        avatars.append(saved)
    }

    func getAvatar(id: String) async throws -> Avatar {
        guard let avatar = avatars.first(where: { $0.avatarId == id }) else { throw UITestFailure.requested }
        return avatar
    }

    func deleteAvatar(id: String) async throws {
        avatars.removeAll { $0.avatarId == id }
    }

    func getFeaturedAvatars() async throws -> [Avatar] { avatars }
    func getPopularAvatars() async throws -> [Avatar] { avatars }

    func getAvatarsByCategory(_ category: CharacterOption) async throws -> [Avatar] {
        if scenario == .categoryFailure { throw UITestFailure.requested }
        if scenario == .emptyCategory { return [] }
        return avatars.filter { $0.characterOption == category }
    }

    func getCurrentUserAvatars(userId: String) async throws -> [Avatar] {
        if scenario == .profileFailure { throw UITestFailure.requested }
        return avatars.filter { $0.authorId == userId }
    }

    func incrementAvatarClickCount(avatarId: String) async throws { }
    func removeAuthorIdFromTheDeletedUserAvatars(userId: String) async throws { }
}

@MainActor
final class UITestAvatarPersistence: LocalAvatarPersistence {
    private var avatars: [Avatar]

    init(avatars: [Avatar]) { self.avatars = Array(avatars.prefix(2)) }

    func addRecentAvatar(avatar: Avatar) throws {
        avatars.removeAll { $0.avatarId == avatar.avatarId }
        avatars.insert(avatar, at: 0)
    }

    func getRecentAvatars() throws -> [Avatar] { avatars }
}
#endif
