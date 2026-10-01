//
//  LocalABTestService.swift
//  AIChat
//
//  Created by Youssef Mohamed on 29/09/2026.
//

import Foundation

class LocalABTestService: ABTestService {
    @UserDefault(key: ActiveABTests.CodingKeys.createAccountTest.rawValue, startingValue: Bool.random())
    private var createAccountTest: Bool

    @UserDefault(key: ActiveABTests.CodingKeys.onboardingCommunityTest.rawValue, startingValue: Bool.random())
    private var onboardingCommunityTest: Bool

    var activeTests: ActiveABTests {
        ActiveABTests(createAccountTest: createAccountTest, onboardingCommunityTest: onboardingCommunityTest)
    }

    func saveUpdatedConfig(updatedTests: ActiveABTests) throws {
        createAccountTest = updatedTests.createAccountTest
        onboardingCommunityTest = updatedTests.onboardingCommunityTest
    }
}
