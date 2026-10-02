#if MOCK
import Foundation

struct UITestUserServices: UserServicesContainer {
    let remote: RemoteUserService
    let local: LocalUserPersistence

    init(config: UITestConfiguration) {
        remote = UITestUserService(config: config)
        local = MockUserPersistence(currentUser: config.user)
    }
}

@MainActor
final class UITestUserService: RemoteUserService {
    private var user: UserModel
    private let scenario: UITestScenario
    private var continuations: [UUID: AsyncThrowingStream<UserModel, Error>.Continuation] = [:]

    init(config: UITestConfiguration) {
        user = config.user
        scenario = config.scenario
    }

    func streamUser(userId: String) -> AsyncThrowingStream<UserModel, Error> {
        let id = UUID()
        return AsyncThrowingStream { continuation in
            continuations[id] = continuation
            continuation.yield(user)
            continuation.onTermination = { [weak self] _ in
                Task { @MainActor in self?.continuations.removeValue(forKey: id) }
            }
        }
    }

    func saveUser(_ value: UserModel) async throws {
        user = UserModel(userId: value.userId, email: value.email, isAnonymous: value.isAnonymous, creationDate: value.creationDate, creationVersion: value.creationVersion, lastSignInDate: value.lastSignInDate, didCompleteOnboarding: user.didCompleteOnboarding, profileColorHex: user.profileColorHex)
        publish()
    }

    func markOnboardingAsCompleted(userId: String, profileColorHex: String) async throws {
        if scenario == .slowOnboarding { try await Task.sleep(for: .seconds(2)) }
        if scenario == .onboardingFailure { throw UITestFailure.requested }
        user = UserModel(userId: user.userId, email: user.email, isAnonymous: user.isAnonymous, didCompleteOnboarding: true, profileColorHex: profileColorHex)
        publish()
    }

    func deleteUser(userId: String) async throws {
        if scenario == .deleteAccountFailure { throw UITestFailure.requested }
    }

    private func publish() {
        for continuation in continuations.values { continuation.yield(user) }
    }
}
#endif
