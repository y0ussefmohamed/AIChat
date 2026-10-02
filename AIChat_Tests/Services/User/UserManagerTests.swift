import Foundation
import SwiftfulUtilities
import Testing
@testable import AIChat

@MainActor
struct UserManagerTests {

    @Test("Initialization restores the cached user without making remote calls")
    func init_restoresLocalUser() {
        let user = UserModel(userId: "cached_user", email: "cached@example.com")
        let fixture = makeManager(user: user)
        let manager = fixture.manager
        let remote = fixture.remote
        let local = fixture.local

        #expect(manager.currentUser?.userId == "cached_user")
        #expect(manager.currentUser?.email == "cached@example.com")
        #expect(local.getCallCount == 1)
        #expect(remote.savedUsers.isEmpty)
        #expect(remote.streamUserIDs.isEmpty)
    }

    @Test("Initialization without a cached user leaves currentUser nil")
    func init_withoutCachedUser_leavesUserNil() {
        let fixture = makeManager()
        let manager = fixture.manager
        let local = fixture.local

        #expect(manager.currentUser == nil)
        #expect(local.getCallCount == 1)
    }

    @Test("Login saves mapped authentication fields and sets creation version only for new users", arguments: [false, true])
    func logIn_savesAuthAndStartsListener(isNewUser: Bool) async throws {
        let auth = makeAuth()
        let fixture = makeManager()
        let manager = fixture.manager
        let remote = fixture.remote
        let log = fixture.log
        defer { remote.finishStream() }

        try await manager.logIn(auth: auth, isNewUser: isNewUser)

        #expect(remote.savedUsers.count == 1)
        let saved = try #require(remote.savedUsers.first)
        #expect(saved.userId == auth.uid)
        #expect(saved.email == auth.email)
        #expect(saved.isAnonymous == auth.isAnonymous)
        #expect(saved.creationDate == auth.creationDate)
        #expect(saved.lastSignInDate == auth.lastSignInDate)
        #expect(saved.creationVersion == (isNewUser ? SwiftfulUtilities.Utilities.appVersion : nil))
        #expect(saved.didCompleteOnboarding == nil)
        #expect(saved.profileColorHex == nil)
        let listening = await waitForManagerCondition { remote.streamUserIDs == [auth.uid] }
        #expect(listening)
        #expect(remote.calls == ["save:user_123", "stream:user_123"])
        #expect(log.events.map(\.name) == ["UserManager_LogIn_Start", "UserManager_LogIn_Success"])
        #expect(log.events.last?.parameters?["is_new_user"] as? Bool == isNewUser)
    }

    @Test("A login save failure preserves the cached user and does not start a listener")
    func logIn_whenSaveFails_preservesState() async {
        let fixture = makeManager(user: UserModel(userId: "cached_user"))
        let manager = fixture.manager
        let remote = fixture.remote
        let local = fixture.local
        let log = fixture.log
        remote.saveError = ManagerTestError.requested

        await #expect(throws: ManagerTestError.requested) {
            try await manager.logIn(auth: makeAuth(), isNewUser: true)
        }
        #expect(manager.currentUser?.userId == "cached_user")
        #expect(remote.streamUserIDs.isEmpty)
        #expect(local.savedUsers.isEmpty)
        #expect(log.events.map(\.name) == ["UserManager_LogIn_Start", "UserManager_LogIn_Fail"])
        #expect(log.events.last?.type == .severe)
    }

    @Test("Stream updates replace currentUser, update logging properties, and save the cache")
    func userStream_updatesStateAndLocalPersistence() async throws {
        let fixture = makeManager()
        let manager = fixture.manager
        let remote = fixture.remote
        let local = fixture.local
        let log = fixture.log
        defer { remote.finishStream() }
        try await manager.logIn(auth: makeAuth(), isNewUser: false)
        let listening = await waitForManagerCondition { remote.continuation != nil }
        #expect(listening)
        let first = UserModel(userId: "user_123", email: "first@example.com", didCompleteOnboarding: false)

        remote.continuation?.yield(first)
        let firstSaved = await waitForManagerCondition { local.savedUsers.count == 1 }
        #expect(firstSaved)
        #expect(manager.currentUser?.email == "first@example.com")
        #expect(manager.currentUser?.didCompleteOnboarding == false)
        #expect(local.currentUser?.email == "first@example.com")

        let second = UserModel(userId: "user_123", email: "updated@example.com", didCompleteOnboarding: true, profileColorHex: "#123456")
        remote.continuation?.yield(second)
        let secondSaved = await waitForManagerCondition { local.savedUsers.count == 2 }
        #expect(secondSaved)
        #expect(manager.currentUser?.email == "updated@example.com")
        #expect(manager.currentUser?.didCompleteOnboarding == true)
        #expect(manager.currentUser?.profileColorHex == "#123456")
        #expect(local.currentUser?.email == "updated@example.com")
        #expect(log.events.filter { $0.name == "UserManager_StreamUser_Success" }.count == 2)
        try #require(log.userProperties.count == 4)
        #expect(log.userProperties[2].properties["user_email"] as? String == "updated@example.com")
    }

    @Test("A stream failure is logged without discarding the cached user")
    func userStream_whenStreamFails_preservesStateAndLogsError() async throws {
        let fixture = makeManager(user: UserModel(userId: "cached_user"))
        let manager = fixture.manager
        let remote = fixture.remote
        let log = fixture.log
        defer { remote.finishStream() }
        try await manager.logIn(auth: makeAuth(), isNewUser: false)
        let listening = await waitForManagerCondition { remote.continuation != nil }
        #expect(listening)

        remote.finishStream(throwing: ManagerTestError.requested)
        let logged = await waitForManagerCondition { log.events.contains { $0.name == "UserManager_StreamUser_Fail" } }

        #expect(logged)
        #expect(manager.currentUser?.userId == "cached_user")
        #expect(log.events.last?.type == .severe)
    }

    @Test("A local cache save failure is logged while the streamed user remains current")
    func userStream_whenLocalSaveFails_preservesStreamedState() async throws {
        let fixture = makeManager()
        let manager = fixture.manager
        let remote = fixture.remote
        let local = fixture.local
        let log = fixture.log
        defer { remote.finishStream() }
        local.saveError = ManagerTestError.requested
        try await manager.logIn(auth: makeAuth(), isNewUser: false)
        let listening = await waitForManagerCondition { remote.continuation != nil }
        #expect(listening)

        remote.continuation?.yield(UserModel(userId: "user_123", email: "streamed@example.com"))
        let logged = await waitForManagerCondition { log.events.contains { $0.name == "UserManager_SaveUserLocally_Fail" } }

        #expect(logged)
        #expect(manager.currentUser?.email == "streamed@example.com")
        #expect(local.currentUser == nil)
        #expect(local.savedUsers.count == 1)
        #expect(log.events.last?.type == .severe)
    }

    @Test("Completing onboarding forwards the current user ID and selected color")
    func markOnboardingAsCompleted_forwardsCurrentUserAndColor() async throws {
        let fixture = makeManager(user: UserModel(userId: "user_123"))
        let manager = fixture.manager
        let remote = fixture.remote
        let log = fixture.log

        try await manager.markOnboardingAsCompleted(profileColorHex: "#123456")

        #expect(remote.onboardingUserID == "user_123")
        #expect(remote.onboardingColor == "#123456")
        #expect(log.events.map(\.name) == ["UserManager_MarkOnboarding_Start", "UserManager_MarkOnboarding_Success"])
        #expect(log.events.first?.parameters?["profile_color_hex"] as? String == "#123456")
    }

    @Test("Completing onboarding without a current user fails before calling the service")
    func markOnboardingAsCompleted_withoutUser_throwsNoUserID() async {
        let fixture = makeManager()
        let manager = fixture.manager
        let remote = fixture.remote
        let log = fixture.log

        await #expect(throws: UserManagerError.noUserId) {
            try await manager.markOnboardingAsCompleted(profileColorHex: "#123456")
        }
        #expect(remote.onboardingUserID == nil)
        #expect(log.events.map(\.name) == ["UserManager_MarkOnboarding_Start", "UserManager_MarkOnboarding_Fail"])
    }

    @Test("Onboarding errors propagate and preserve the current user")
    func markOnboardingAsCompleted_propagatesError() async {
        let fixture = makeManager(user: UserModel(userId: "user_123"))
        let manager = fixture.manager
        let remote = fixture.remote
        let log = fixture.log
        remote.onboardingError = ManagerTestError.requested

        await #expect(throws: ManagerTestError.requested) {
            try await manager.markOnboardingAsCompleted(profileColorHex: "#123456")
        }
        #expect(manager.currentUser?.userId == "user_123")
        #expect(log.events.last?.name == "UserManager_MarkOnboarding_Fail")
        #expect(log.events.last?.type == .warning)
    }

    @Test("Signing out clears currentUser and logs the previous user's identity")
    func signOut_clearsStateAndLogsPreviousUser() {
        let fixture = makeManager(user: UserModel(userId: "user_123"))
        let manager = fixture.manager
        let remote = fixture.remote
        let log = fixture.log

        manager.signOut()

        #expect(manager.currentUser == nil)
        #expect(remote.calls.isEmpty)
        #expect(log.events.map(\.name) == ["UserManager_SignOut"])
        #expect(log.events.first?.parameters?["user_user_id"] as? String == "user_123")
    }

    @Test("Signing out without a user is safe")
    func signOut_withoutUser_leavesStateNil() {
        let fixture = makeManager()
        let manager = fixture.manager
        let log = fixture.log

        manager.signOut()

        #expect(manager.currentUser == nil)
        #expect(log.events.first?.name == "UserManager_SignOut")
        #expect(log.events.first?.parameters == nil)
    }

    @Test("Deleting the current user forwards its ID and signs out after successful deletion")
    func deleteCurrentUser_deletesAndSignsOut() async throws {
        let fixture = makeManager(user: UserModel(userId: "user_123"))
        let manager = fixture.manager
        let remote = fixture.remote
        let log = fixture.log

        try await manager.deleteCurrentUser()

        #expect(remote.deletedUserIDs == ["user_123"])
        #expect(manager.currentUser == nil)
        #expect(log.events.map(\.name) == ["UserManager_DeleteUser_Start", "UserManager_DeleteUser_Success", "UserManager_SignOut"])
    }

    @Test("Deleting without a current user throws before calling the remote service")
    func deleteCurrentUser_withoutUser_throwsNoUserID() async {
        let fixture = makeManager()
        let manager = fixture.manager
        let remote = fixture.remote
        let log = fixture.log

        await #expect(throws: UserManagerError.noUserId) {
            try await manager.deleteCurrentUser()
        }
        #expect(remote.deletedUserIDs.isEmpty)
        #expect(log.events.last?.name == "UserManager_DeleteUser_Fail")
    }

    @Test("A deletion error propagates and preserves the current user")
    func deleteCurrentUser_whenServiceFails_preservesState() async {
        let fixture = makeManager(user: UserModel(userId: "user_123"))
        let manager = fixture.manager
        let remote = fixture.remote
        let log = fixture.log
        remote.deleteError = ManagerTestError.requested

        await #expect(throws: ManagerTestError.requested) {
            try await manager.deleteCurrentUser()
        }
        #expect(manager.currentUser?.userId == "user_123")
        #expect(log.events.map(\.name) == ["UserManager_DeleteUser_Start", "UserManager_DeleteUser_Fail"])
        #expect(log.events.last?.type == .warning)
    }

    private func makeAuth() -> UserAuthInfo {
        UserAuthInfo(uid: "user_123", email: "user@example.com", isAnonymous: false, creationDate: Date(timeIntervalSince1970: 1_700_000_000), lastSignInDate: Date(timeIntervalSince1970: 1_700_000_500))
    }

    private func makeManager(user: UserModel? = nil) -> UserManagerFixture {
        let remote = RecordingRemoteUserService()
        let local = RecordingLocalUserPersistence(user: user)
        let log = RecordingLogService()
        let manager = UserManager(services: TestUserServices(remote: remote, local: local), logManager: LogManager(services: [log]))
        return UserManagerFixture(manager: manager, remote: remote, local: local, log: log)
    }
}

@MainActor
private struct UserManagerFixture {
    let manager: UserManager
    let remote: RecordingRemoteUserService
    let local: RecordingLocalUserPersistence
    let log: RecordingLogService
}

@MainActor
private struct TestUserServices: UserServicesContainer {
    let remote: any RemoteUserService
    let local: any LocalUserPersistence
}

@MainActor
private final class RecordingRemoteUserService: RemoteUserService {
    var savedUsers: [UserModel] = []
    var streamUserIDs: [String] = []
    var continuation: AsyncThrowingStream<UserModel, Error>.Continuation?
    var calls: [String] = []
    var saveError: Error?
    var onboardingError: Error?
    var deleteError: Error?
    var onboardingUserID: String?
    var onboardingColor: String?
    var deletedUserIDs: [String] = []

    func streamUser(userId: String) -> AsyncThrowingStream<UserModel, Error> {
        calls.append("stream:\(userId)")
        streamUserIDs.append(userId)
        let pair = AsyncThrowingStream<UserModel, Error>.makeStream()
        continuation = pair.continuation
        return pair.stream
    }

    func finishStream(throwing error: Error? = nil) {
        continuation?.finish(throwing: error)
        continuation = nil
    }

    func saveUser(_ user: UserModel) async throws {
        calls.append("save:\(user.userId)")
        savedUsers.append(user)
        if let saveError { throw saveError }
    }

    func markOnboardingAsCompleted(userId: String, profileColorHex: String) async throws {
        calls.append("onboarding:\(userId)")
        onboardingUserID = userId
        onboardingColor = profileColorHex
        if let onboardingError { throw onboardingError }
    }

    func deleteUser(userId: String) async throws {
        calls.append("delete:\(userId)")
        deletedUserIDs.append(userId)
        if let deleteError { throw deleteError }
    }
}

@MainActor
private final class RecordingLocalUserPersistence: LocalUserPersistence {
    var currentUser: UserModel?
    var getCallCount = 0
    var savedUsers: [UserModel?] = []
    var saveError: Error?

    init(user: UserModel?) { currentUser = user }

    func getCurrentUser() -> UserModel? {
        getCallCount += 1
        return currentUser
    }

    func saveCurrentUser(_ user: UserModel?) throws {
        savedUsers.append(user)
        if let saveError { throw saveError }
        currentUser = user
    }
}
