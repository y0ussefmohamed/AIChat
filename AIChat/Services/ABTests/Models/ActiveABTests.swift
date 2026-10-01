//
//  ActiveABTests.swift
//  AIChat
//
//  Created by Youssef Mohamed on 29/09/2026.
//

import Foundation

/// Model Holds ABTests Statuses whether is the test active or not
struct ActiveABTests: Codable {
    private(set) var createAccountTest: Bool
    private(set) var onboardingCommunityTest: Bool

    init(createAccountTest: Bool, onboardingCommunityTest: Bool) {
        self.createAccountTest = createAccountTest
        self.onboardingCommunityTest = onboardingCommunityTest
    }

    enum CodingKeys: String, CodingKey {
        case createAccountTest = "_2026299_CreateAccountABTest"
        case onboardingCommunityTest = "_2026299_OnboardingCommunityABTest"
    }

    var asEventParamaters: [String: Any] {
        let dict: [String: Any?] = [
            "test\(CodingKeys.createAccountTest.rawValue)": createAccountTest,
            "test\(CodingKeys.onboardingCommunityTest.rawValue)": onboardingCommunityTest
        ]

        return dict.compactMapValues { $0 }
    }

    mutating func update(createAccountTest newValue: Bool) {
        createAccountTest = newValue
    }

    mutating func update(onboardingCommunityTest newValue: Bool) {
        onboardingCommunityTest = newValue
    }
}
