//
//  ActiveABTests.swift
//  AIChat
//
//  Created by Youssef Mohamed on 29/09/2026.
//

import Foundation

/// Model Holds ABTests Statuses whether is the test active or not
struct ActiveABTests: Codable {
    let createAccountTest: Bool

    init(createAccountTest: Bool) {
        self.createAccountTest = createAccountTest
    }

    enum CodingKeys: String, CodingKey {
        case createAccountTest = "_2026299_CreateAccountABTest"
    }

    var asEventParamaters: [String: Any] {
        let dict: [String: Any?] = [
            "test\(CodingKeys.createAccountTest.rawValue)": createAccountTest,
        ]

        return dict.compactMapValues { $0 }
    }
}
