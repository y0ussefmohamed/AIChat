//
//  FirebaseABTestService.swift
//  AIChat
//
//  Created by Youssef Mohamed on 01/10/2026.
//

import Foundation
import FirebaseRemoteConfig

final class FirebaseABTestService: ABTestService {
    private let logManager: LogManager?

    var activeTests: ActiveABTests {
        ActiveABTests(config: RemoteConfig.remoteConfig())
    }

    init(logManager: LogManager? = nil) {
        self.logManager = logManager

        let remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings

        let defaultTests = ActiveABTests(createAccountTest: false, onboardingCommunityTest: false, categoryRowTest: .default)

        remoteConfig.setDefaults(defaultTests.asNSObject)
        remoteConfig.activate()
    }

    func saveUpdatedConfig(updatedTests: ActiveABTests) throws {
        // This violates interface segregation principle but won't make multiple protocols now for faster development
        // Remote Config values cannot be written to Firebase
        // directly from the client app.
    }

    func fetchUpdatedConfig() async throws -> ActiveABTests {
        logManager?.trackEvent(event: FirebaseABTestServiceEvent.fetchUpdatedConfigStart)

        do {
            let status = try await RemoteConfig.remoteConfig().fetchAndActivate()
            switch status {
            case .successFetchedFromRemote, .successUsingPreFetchedData:
                let updatedTests = activeTests
                logManager?.trackEvent(event: FirebaseABTestServiceEvent.fetchUpdatedConfigSuccess(tests: updatedTests))
                return updatedTests
            case .error:
                throw RemoteConfigError.failedToFetch
            default:
                throw RemoteConfigError.failedToFetch
            }
        } catch {
            logManager?.trackEvent(event: FirebaseABTestServiceEvent.fetchUpdatedConfigFail(error: error))
            throw error
        }
    }
}

extension FirebaseABTestService {

    enum FirebaseABTestServiceEvent: LoggableEvent {
        case fetchUpdatedConfigStart
        case fetchUpdatedConfigSuccess(tests: ActiveABTests)
        case fetchUpdatedConfigFail(error: Error)

        var eventName: String {
            switch self {
            case .fetchUpdatedConfigStart:
                return "FirebaseABTestService_FetchUpdatedConfig_Start"
            case .fetchUpdatedConfigSuccess:
                return "FirebaseABTestService_FetchUpdatedConfig_Success"
            case .fetchUpdatedConfigFail:
                return "FirebaseABTestService_FetchUpdatedConfig_Fail"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .fetchUpdatedConfigStart:
                return nil
            case .fetchUpdatedConfigSuccess(tests: let tests):
                return tests.asEventParameter
            case .fetchUpdatedConfigFail(error: let error):
                return error.asEventParameter
            }
        }

        var type: LogType {
            switch self {
            case .fetchUpdatedConfigFail:
                return .warning
            default:
                return .analytic
            }
        }
    }
}


extension ActiveABTests {
    init(config: RemoteConfig) {
        let createAccountTest = config.configValue(forKey: CodingKeys.createAccountTest.rawValue).boolValue
        let onboardingCommunityTest = config.configValue(forKey: CodingKeys.onboardingCommunityTest.rawValue).boolValue
        let categoryRowTestString = config.configValue(forKey: CodingKeys.categoryRowTest.rawValue).stringValue

        self.init(
            createAccountTest: createAccountTest,
            onboardingCommunityTest: onboardingCommunityTest,
            categoryRowTest: CategoryRowTestOption(rawValue: categoryRowTestString) ?? .default
        )
    }

    /// converting this tests for the `setDefaults` method in `Firebase remoteConfig`
    var asNSObject: [String: NSObject] {
        [
            CodingKeys.createAccountTest.rawValue: NSNumber(value: createAccountTest),
            CodingKeys.onboardingCommunityTest.rawValue: NSNumber(value: onboardingCommunityTest),
            CodingKeys.categoryRowTest.rawValue: categoryRowTest.rawValue as NSString
        ]
    }
}
