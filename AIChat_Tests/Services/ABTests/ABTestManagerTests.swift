import Testing
@testable import AIChat

@MainActor
struct ABTestManagerTests {

    @Test("Initialization exposes the service's current configuration immediately")
    func init_setsInitialConfiguration() {
        let service = RecordingABTestService()
        let manager = ABTestManager(service: service)

        #expect(manager.activeTests.createAccountTest == false)
        #expect(manager.activeTests.onboardingCommunityTest == true)
        #expect(manager.activeTests.categoryRowTest == .original)
        #expect(manager.canOverrideTests == false)
    }

    @Test("An editable service enables overrides")
    func canOverrideTests_withEditableService_returnsTrue() {
        let manager = ABTestManager(service: RecordingEditableABTestService())

        #expect(manager.canOverrideTests == true)
    }

    @Test("Initialization fetches updated configuration and exposes the new values")
    func init_fetchesUpdatedConfiguration() async {
        let service = RecordingABTestService()
        service.nextConfig = updatedTests()
        let manager = ABTestManager(service: service)

        let updated = await waitForManagerCondition { manager.activeTests.categoryRowTest == .hidden }

        #expect(updated)
        #expect(service.fetchCallCount == 1)
        #expect(manager.activeTests.createAccountTest == true)
        #expect(manager.activeTests.onboardingCommunityTest == false)
        #expect(manager.activeTests.categoryRowTest == .hidden)
    }

    @Test("A fetch error preserves the initial configuration")
    func init_whenFetchFails_preservesConfiguration() async {
        let service = RecordingABTestService()
        service.fetchError = ManagerTestError.requested
        let manager = ABTestManager(service: service)

        let fetched = await waitForManagerCondition { service.fetchCallCount == 1 }

        #expect(fetched)
        #expect(manager.activeTests.createAccountTest == false)
        #expect(manager.activeTests.onboardingCommunityTest == true)
        #expect(manager.activeTests.categoryRowTest == .original)
    }

    @Test("Initialization forwards initial remote config properties to logging")
    func init_configuresUserProperties() throws {
        let log = RecordingLogService()
        _ = ABTestManager(service: RecordingABTestService(), logManager: LogManager(services: [log]))

        #expect(log.userProperties.count == 1)
        let call = try #require(log.userProperties.first)
        #expect(call.isHighPriority == false)
        #expect(call.properties["test_2026299_CreateAccountABTest"] as? Bool == false)
        #expect(call.properties["test_2026299_OnboardingCommunityABTest"] as? Bool == true)
        #expect(call.properties["test_20260110_CategoryRowABTest"] as? String == "original")
    }

    @Test("Overriding a read-only service throws and preserves active tests")
    func override_withReadOnlyService_throwsNotSupported() {
        let service = RecordingABTestService()
        let manager = ABTestManager(service: service)

        #expect(throws: ABTestManager.OverrideError.notSupported) {
            try manager.override(updatedTests: updatedTests())
        }
        #expect(manager.activeTests.createAccountTest == false)
        #expect(manager.activeTests.onboardingCommunityTest == true)
        #expect(manager.activeTests.categoryRowTest == .original)
    }

    @Test("Overriding saves the supplied configuration and refreshes exposed values")
    func override_savesConfigurationAndRefreshesState() async throws {
        let service = RecordingEditableABTestService()
        let manager = ABTestManager(service: service)
        let fetched = await waitForManagerCondition { service.fetchCallCount == 1 }
        #expect(fetched)

        try manager.override(updatedTests: updatedTests())

        #expect(service.savedConfigs.count == 1)
        let saved = try #require(service.savedConfigs.first)
        #expect(saved.createAccountTest == true)
        #expect(saved.onboardingCommunityTest == false)
        #expect(saved.categoryRowTest == .hidden)
        #expect(manager.activeTests.createAccountTest == true)
        #expect(manager.activeTests.onboardingCommunityTest == false)
        #expect(manager.activeTests.categoryRowTest == .hidden)
        let fetchedAgain = await waitForManagerCondition { service.fetchCallCount == 2 }
        #expect(fetchedAgain)
    }

    @Test("Overriding reads back the service's saved configuration")
    func override_usesServiceConfigurationAfterSave() throws {
        let service = RecordingEditableABTestService()
        service.savedConfigOverride = ActiveABTests(createAccountTest: false, onboardingCommunityTest: false, categoryRowTest: .top)
        let manager = ABTestManager(service: service)

        try manager.override(updatedTests: updatedTests())

        #expect(manager.activeTests.createAccountTest == false)
        #expect(manager.activeTests.onboardingCommunityTest == false)
        #expect(manager.activeTests.categoryRowTest == .top)
    }

    @Test("A save failure propagates without changing state or configuring logging again")
    func override_whenSaveFails_preservesState() async {
        let service = RecordingEditableABTestService()
        service.saveError = ManagerTestError.requested
        let log = RecordingLogService()
        let manager = ABTestManager(service: service, logManager: LogManager(services: [log]))
        let fetched = await waitForManagerCondition { service.fetchCallCount == 1 }
        #expect(fetched)

        #expect(throws: ManagerTestError.requested) {
            try manager.override(updatedTests: updatedTests())
        }
        #expect(manager.activeTests.createAccountTest == false)
        #expect(manager.activeTests.onboardingCommunityTest == true)
        #expect(manager.activeTests.categoryRowTest == .original)
        #expect(service.fetchCallCount == 1)
        #expect(log.userProperties.count == 1)
    }

    @Test("A successful override sends updated user properties to logging")
    func override_updatesUserProperties() throws {
        let log = RecordingLogService()
        let manager = ABTestManager(service: RecordingEditableABTestService(), logManager: LogManager(services: [log]))

        try manager.override(updatedTests: updatedTests())

        #expect(log.userProperties.count == 2)
        let call = try #require(log.userProperties.last)
        #expect(call.properties["test_2026299_CreateAccountABTest"] as? Bool == true)
        #expect(call.properties["test_2026299_OnboardingCommunityABTest"] as? Bool == false)
        #expect(call.properties["test_20260110_CategoryRowABTest"] as? String == "hidden")
    }

    @Test("A refresh failure after overriding preserves the successfully saved configuration")
    func override_whenRefreshFails_preservesSavedConfiguration() async throws {
        let service = RecordingEditableABTestService()
        let manager = ABTestManager(service: service)
        let initialFetch = await waitForManagerCondition { service.fetchCallCount == 1 }
        #expect(initialFetch)
        service.fetchError = ManagerTestError.requested

        try manager.override(updatedTests: updatedTests())
        let attemptedRefresh = await waitForManagerCondition { service.fetchCallCount == 2 }

        #expect(attemptedRefresh)
        #expect(manager.activeTests.createAccountTest == true)
        #expect(manager.activeTests.onboardingCommunityTest == false)
        #expect(manager.activeTests.categoryRowTest == .hidden)
    }

    private func updatedTests() -> ActiveABTests {
        ActiveABTests(createAccountTest: true, onboardingCommunityTest: false, categoryRowTest: .hidden)
    }
}

@MainActor
private class RecordingABTestService: ABTestService {
    var activeTests = ActiveABTests(createAccountTest: false, onboardingCommunityTest: true, categoryRowTest: .original)
    var nextConfig: ActiveABTests?
    var fetchError: Error?
    var fetchCallCount = 0

    func fetchUpdatedConfig() async throws -> ActiveABTests {
        fetchCallCount += 1
        if let fetchError { throw fetchError }
        if let nextConfig { activeTests = nextConfig }
        return activeTests
    }
}

@MainActor
private final class RecordingEditableABTestService: RecordingABTestService, EditableABTestService {
    var saveError: Error?
    var savedConfigs: [ActiveABTests] = []
    var savedConfigOverride: ActiveABTests?

    func saveUpdatedConfig(updatedTests: ActiveABTests) throws {
        savedConfigs.append(updatedTests)
        if let saveError { throw saveError }
        activeTests = savedConfigOverride ?? updatedTests
    }
}
