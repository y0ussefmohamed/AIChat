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
    private(set) var categoryRowTest: CategoryRowTestOption

    init(createAccountTest: Bool, onboardingCommunityTest: Bool, categoryRowTest: CategoryRowTestOption) {
        self.createAccountTest = createAccountTest
        self.onboardingCommunityTest = onboardingCommunityTest
        self.categoryRowTest = categoryRowTest
    }

    enum CodingKeys: String, CodingKey {
        case createAccountTest = "_2026299_CreateAccountABTest"
        case onboardingCommunityTest = "_2026299_OnboardingCommunityABTest"
        case categoryRowTest = "_20260110_CategoryRowABTest"
    }

    var asEventParamaters: [String: Any] {
        let dict: [String: Any?] = [
            "test\(CodingKeys.createAccountTest.rawValue)": createAccountTest,
            "test\(CodingKeys.onboardingCommunityTest.rawValue)": onboardingCommunityTest,
            "test\(CodingKeys.categoryRowTest.rawValue)": categoryRowTest.rawValue
        ]

        return dict.compactMapValues { $0 }
    }

    mutating func update(createAccountTest newValue: Bool) {
        createAccountTest = newValue
    }

    mutating func update(onboardingCommunityTest newValue: Bool) {
        onboardingCommunityTest = newValue
    }

    mutating func update(categoryRowTest newValue: CategoryRowTestOption) {
        categoryRowTest = newValue
    }
}
