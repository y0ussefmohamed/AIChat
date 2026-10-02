//
//  UserModelTests.swift
//  AIChat_Tests
//
//  Created by Youssef Mohamed on 02/10/2026.
//

import Foundation
import SwiftUI
import Testing
@testable import AIChat

@MainActor
struct UserModelTests {

    @Test("Initializing with default values sets required properties and leaves optional fields nil")
    func init_withDefaultValues_setsPropertiesCorrectly() {
        let user = UserModel(userId: "user_123")

        #expect(user.userId == "user_123")
        #expect(user.email == nil)
        #expect(user.isAnonymous == nil)
        #expect(user.creationDate == nil)
        #expect(user.creationVersion == nil)
        #expect(user.lastSignInDate == nil)
        #expect(user.didCompleteOnboarding == nil)
        #expect(user.profileColorHex == nil)
    }

    @Test("Initializing from UserAuthInfo correctly maps authentication fields")
    func init_fromUserAuthInfo_mapsPropertiesCorrectly() {
        let creationDate = Date()
        let lastSignInDate = Date().addingTimeInterval(3600)
        let auth = UserAuthInfo(
            uid: "auth_uid_456",
            email: "auth@example.com",
            isAnonymous: true,
            creationDate: creationDate,
            lastSignInDate: lastSignInDate
        )
        let creationVersion = "1.0.0"

        let user = UserModel(auth: auth, creationVersion: creationVersion)

        #expect(user.userId == "auth_uid_456")
        #expect(user.email == "auth@example.com")
        #expect(user.isAnonymous == true)
        #expect(user.creationDate == creationDate)
        #expect(user.creationVersion == creationVersion)
        #expect(user.lastSignInDate == lastSignInDate)
        #expect(user.didCompleteOnboarding == nil)
        #expect(user.profileColorHex == nil)
    }

    @Test("Profile color correctly resolves to accent or specified hex color")
    func profileColor_resolvesCorrectColor() {
        // When profileColorHex is nil, defaults to .accent
        let defaultUser = UserModel(userId: "user_default", profileColorHex: nil)
        #expect(defaultUser.profileColor == .accent)

        // When profileColorHex is provided, returns corresponding Color
        let hex = "#FF6B6B"
        let coloredUser = UserModel(userId: "user_colored", profileColorHex: hex)
        #expect(coloredUser.profileColor == Color(hex: hex))
    }

    @Test("Event parameter dictionary formats keys with prefix and compacts nil values")
    func asEventParameter_containsFormattedKeysAndExcludesNilValues() {
        // When only userId is provided, only user_user_id should be present
        let minimalUser = UserModel(userId: "user_min")
        let minimalParams = minimalUser.asEventParameter

        #expect(minimalParams["user_user_id"] as? String == "user_min")
        #expect(minimalParams["user_email"] == nil)
        #expect(minimalParams["user_is_anonymous"] == nil)
        #expect(minimalParams["user_creation_version"] == nil)
        #expect(minimalParams["user_did_complete_onboarding"] == nil)
        #expect(minimalParams["user_profile_color_hex"] == nil)
        #expect(minimalParams.count == 1)

        // When all fields are provided, all user_ prefixed keys should be present
        let fullUser = UserModel(
            userId: "user_full",
            email: "full@example.com",
            isAnonymous: false,
            creationDate: Date(),
            creationVersion: "2.0.0",
            lastSignInDate: Date(),
            didCompleteOnboarding: true,
            profileColorHex: "#4ECDC4"
        )
        let fullParams = fullUser.asEventParameter

        #expect(fullParams["user_user_id"] as? String == "user_full")
        #expect(fullParams["user_email"] as? String == "full@example.com")
        #expect(fullParams["user_is_anonymous"] as? Bool == false)
        #expect(fullParams["user_creation_version"] as? String == "2.0.0")
        #expect(fullParams["user_did_complete_onboarding"] as? Bool == true)
        #expect(fullParams["user_profile_color_hex"] as? String == "#4ECDC4")
        #expect(fullParams["user_creation_date"] != nil)
        #expect(fullParams["user_last_sign_in_date"] != nil)
        #expect(fullParams.count == 8)
    }

    @Test("Encoding and decoding UserModel through Codable preserves all property values")
    func codable_encodesAndDecodesSuccessfully() throws {
        let original = UserModel(
            userId: "user_codable",
            email: "codable@example.com",
            isAnonymous: false,
            creationDate: Date(timeIntervalSince1970: 1700000000),
            creationVersion: "1.2.3",
            lastSignInDate: Date(timeIntervalSince1970: 1700000500),
            didCompleteOnboarding: true,
            profileColorHex: "#556270"
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        let decoded = try decoder.decode(UserModel.self, from: data)

        #expect(decoded.userId == original.userId)
        #expect(decoded.email == original.email)
        #expect(decoded.isAnonymous == original.isAnonymous)
        #expect(decoded.creationDate == original.creationDate)
        #expect(decoded.creationVersion == original.creationVersion)
        #expect(decoded.lastSignInDate == original.lastSignInDate)
        #expect(decoded.didCompleteOnboarding == original.didCompleteOnboarding)
        #expect(decoded.profileColorHex == original.profileColorHex)
    }

    @Test("Decoding UserModel from snake_case JSON payload matches Firestore schema")
    func codable_decodesFromCustomCodingKeysJSON() throws {
        let json = """
        {
            "user_id": "json_user",
            "email": "json@test.com",
            "is_anonymous": true,
            "creation_version": "3.0.0",
            "did_complete_onboarding": false,
            "profile_color_hex": "#123456"
        }
        """
        let data = try #require(json.data(using: .utf8))
        let user = try JSONDecoder().decode(UserModel.self, from: data)

        #expect(user.userId == "json_user")
        #expect(user.email == "json@test.com")
        #expect(user.isAnonymous == true)
        #expect(user.creationDate == nil)
        #expect(user.creationVersion == "3.0.0")
        #expect(user.lastSignInDate == nil)
        #expect(user.didCompleteOnboarding == false)
        #expect(user.profileColorHex == "#123456")
    }

    @Test("Static mock and mocks provide valid sample instances")
    func mock_returnsExpectedUser() {
        #expect(UserModel.mock.userId == UserModel.mocks[1].userId)
        #expect(UserModel.mock.profileColorHex == UserModel.mocks[1].profileColorHex)
        #expect(UserModel.mocks.count == 4)
    }
}
