//
//  ActiveABTestsModelTests.swift
//  AIChat_Tests
//
//  Created by Youssef Mohamed on 02/10/2026.
//

import Foundation
import Testing
@testable import AIChat

@MainActor
struct ActiveABTestsModelTests {

    @Test("Initializing ActiveABTests sets properties accurately")
    func init_setsPropertiesAccurately() {
        let tests = ActiveABTests(
            createAccountTest: true,
            onboardingCommunityTest: false,
            categoryRowTest: .top
        )

        #expect(tests.createAccountTest == true)
        #expect(tests.onboardingCommunityTest == false)
        #expect(tests.categoryRowTest == .top)
    }

    @Test("Mutating methods update individual test flags and options correctly")
    func updateMethods_mutatePropertiesCorrectly() {
        var tests = ActiveABTests(
            createAccountTest: false,
            onboardingCommunityTest: false,
            categoryRowTest: .original
        )

        tests.update(createAccountTest: true)
        #expect(tests.createAccountTest == true)

        tests.update(onboardingCommunityTest: true)
        #expect(tests.onboardingCommunityTest == true)

        tests.update(categoryRowTest: .hidden)
        #expect(tests.categoryRowTest == .hidden)
    }

    @Test("asEventParameter returns dictionary formatted with human-readable event keys")
    func asEventParameter_returnsExpectedKeysAndValues() {
        let tests = ActiveABTests(
            createAccountTest: true,
            onboardingCommunityTest: false,
            categoryRowTest: .top
        )

        let params = tests.asEventParameter

        #expect(params["is_create_account_test_active"] as? Bool == true)
        #expect(params["is_onboarding_community_test_active"] as? Bool == false)
        #expect(params["category_row_test"] as? String == CategoryRowTestOption.top.rawValue)
        #expect(params.count == 3)
    }

    @Test("asEventParamaters returns dictionary formatted with remote config test keys")
    func asEventParamaters_returnsKeysWithTestPrefix() {
        let tests = ActiveABTests(
            createAccountTest: false,
            onboardingCommunityTest: true,
            categoryRowTest: .original
        )

        let params = tests.asEventParamaters

        let expectedCreateAccountKey = "test\(ActiveABTests.CodingKeys.createAccountTest.rawValue)"
        let expectedCommunityKey = "test\(ActiveABTests.CodingKeys.onboardingCommunityTest.rawValue)"
        let expectedCategoryRowKey = "test\(ActiveABTests.CodingKeys.categoryRowTest.rawValue)"

        #expect(params[expectedCreateAccountKey] as? Bool == false)
        #expect(params[expectedCommunityKey] as? Bool == true)
        #expect(params[expectedCategoryRowKey] as? String == CategoryRowTestOption.original.rawValue)
        #expect(params.count == 3)
    }

    @Test("ActiveABTests encodes and decodes properly through Codable")
    func codable_encodesAndDecodesSuccessfully() throws {
        let original = ActiveABTests(
            createAccountTest: true,
            onboardingCommunityTest: true,
            categoryRowTest: .hidden
        )

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ActiveABTests.self, from: data)

        #expect(decoded.createAccountTest == original.createAccountTest)
        #expect(decoded.onboardingCommunityTest == original.onboardingCommunityTest)
        #expect(decoded.categoryRowTest == original.categoryRowTest)
    }

    @Test("ActiveABTests decodes successfully from JSON matching remote config CodingKeys")
    func codable_decodesFromRemoteConfigJSON() throws {
        let json = """
        {
            "_2026299_CreateAccountABTest": true,
            "_2026299_OnboardingCommunityABTest": false,
            "_20260110_CategoryRowABTest": "top"
        }
        """

        let data = try #require(json.data(using: .utf8))
        let decoded = try JSONDecoder().decode(ActiveABTests.self, from: data)

        #expect(decoded.createAccountTest == true)
        #expect(decoded.onboardingCommunityTest == false)
        #expect(decoded.categoryRowTest == .top)
    }

    @Test("Updating create-account status leaves other settings unchanged and can disable the test")
    func updateCreateAccount_preservesOtherProperties() {
        var tests = ActiveABTests(createAccountTest: false, onboardingCommunityTest: true, categoryRowTest: .top)

        tests.update(createAccountTest: true)
        #expect(tests.createAccountTest == true)
        #expect(tests.onboardingCommunityTest == true)
        #expect(tests.categoryRowTest == .top)

        tests.update(createAccountTest: false)
        #expect(tests.createAccountTest == false)
        #expect(tests.onboardingCommunityTest == true)
        #expect(tests.categoryRowTest == .top)
    }

    @Test("Updating community status leaves other settings unchanged and can disable the test")
    func updateCommunity_preservesOtherProperties() {
        var tests = ActiveABTests(createAccountTest: true, onboardingCommunityTest: false, categoryRowTest: .hidden)

        tests.update(onboardingCommunityTest: true)
        #expect(tests.createAccountTest == true)
        #expect(tests.onboardingCommunityTest == true)
        #expect(tests.categoryRowTest == .hidden)

        tests.update(onboardingCommunityTest: false)
        #expect(tests.createAccountTest == true)
        #expect(tests.onboardingCommunityTest == false)
        #expect(tests.categoryRowTest == .hidden)
    }

    @Test("Updating category placement leaves both feature flags unchanged")
    func updateCategoryRow_preservesOtherProperties() {
        var tests = ActiveABTests(createAccountTest: true, onboardingCommunityTest: false, categoryRowTest: .original)

        tests.update(categoryRowTest: .top)
        #expect(tests.createAccountTest == true)
        #expect(tests.onboardingCommunityTest == false)
        #expect(tests.categoryRowTest == .top)

        tests.update(categoryRowTest: .original)
        #expect(tests.createAccountTest == true)
        #expect(tests.onboardingCommunityTest == false)
        #expect(tests.categoryRowTest == .original)
    }

    @Test("Encoding uses the exact remote config schema")
    func codable_encodesExpectedKeys() throws {
        let tests = ActiveABTests(createAccountTest: false, onboardingCommunityTest: true, categoryRowTest: .hidden)
        let data = try JSONEncoder().encode(tests)
        let json = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])

        #expect(Set(json.keys) == ["_2026299_CreateAccountABTest", "_2026299_OnboardingCommunityABTest", "_20260110_CategoryRowABTest"])
        #expect(json["_2026299_CreateAccountABTest"] as? Bool == false)
        #expect(json["_2026299_OnboardingCommunityABTest"] as? Bool == true)
        #expect(json["_20260110_CategoryRowABTest"] as? String == "hidden")
    }

    @Test("Remote config parameters use literal test-prefixed schema keys")
    func asEventParamaters_matchesRemoteConfigContract() {
        let parameters = ActiveABTests(createAccountTest: false, onboardingCommunityTest: false, categoryRowTest: .hidden).asEventParamaters

        #expect(Set(parameters.keys) == ["test_2026299_CreateAccountABTest", "test_2026299_OnboardingCommunityABTest", "test_20260110_CategoryRowABTest"])
        #expect(parameters["test_2026299_CreateAccountABTest"] as? Bool == false)
        #expect(parameters["test_2026299_OnboardingCommunityABTest"] as? Bool == false)
        #expect(parameters["test_20260110_CategoryRowABTest"] as? String == "hidden")
    }

    @Test("Decoding requires each remote config field", arguments: ["_2026299_CreateAccountABTest", "_2026299_OnboardingCommunityABTest", "_20260110_CategoryRowABTest"])
    func codable_rejectsMissingRequiredField(key: String) throws {
        var json: [String: Any] = [
            "_2026299_CreateAccountABTest": true,
            "_2026299_OnboardingCommunityABTest": false,
            "_20260110_CategoryRowABTest": "top"
        ]
        json.removeValue(forKey: key)
        let data = try JSONSerialization.data(withJSONObject: json)

        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(ActiveABTests.self, from: data)
        }
    }

    @Test("Decoding rejects a malformed feature flag")
    func codable_rejectsInvalidFlagType() {
        let data = Data("""
        {"_2026299_CreateAccountABTest":"true","_2026299_OnboardingCommunityABTest":false,
         "_20260110_CategoryRowABTest":"top"}
        """.utf8)

        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(ActiveABTests.self, from: data)
        }
    }
}
