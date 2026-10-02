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

    @Test("Initializing from minimal authentication preserves nil optional fields and a false anonymous flag")
    func init_fromMinimalAuth_preservesOptionalValues() {
        let user = UserModel(auth: UserAuthInfo(uid: "minimal"), creationVersion: nil)

        #expect(user.userId == "minimal")
        #expect(user.email == nil)
        #expect(user.isAnonymous == false)
        #expect(user.creationDate == nil)
        #expect(user.creationVersion == nil)
        #expect(user.lastSignInDate == nil)
        #expect(user.didCompleteOnboarding == nil)
        #expect(user.profileColorHex == nil)
    }

    @Test("Encoding uses all persisted snake_case keys and Unix dates")
    func codable_encodesExpectedKeys() throws {
        let user = UserModel(
            userId: "user_123", email: "user@example.com", isAnonymous: false,
            creationDate: Date(timeIntervalSince1970: 1_700_000_000), creationVersion: "1.2.3",
            lastSignInDate: Date(timeIntervalSince1970: 1_700_000_500),
            didCompleteOnboarding: false, profileColorHex: "#123456"
        )
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        let data = try encoder.encode(user)
        let json = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])

        #expect(Set(json.keys) == [
            "user_id", "email", "is_anonymous", "creation_date", "creation_version",
            "last_sign_in_date", "did_complete_onboarding", "profile_color_hex"
        ])
        #expect(json["user_id"] as? String == "user_123")
        #expect(json["email"] as? String == "user@example.com")
        #expect(json["is_anonymous"] as? Bool == false)
        #expect(json["creation_date"] as? Double == 1_700_000_000)
        #expect(json["creation_version"] as? String == "1.2.3")
        #expect(json["last_sign_in_date"] as? Double == 1_700_000_500)
        #expect(json["did_complete_onboarding"] as? Bool == false)
        #expect(json["profile_color_hex"] as? String == "#123456")

        let minimalData = try encoder.encode(UserModel(userId: "minimal"))
        let minimalJSON = try #require(JSONSerialization.jsonObject(with: minimalData) as? [String: Any])
        #expect(Set(minimalJSON.keys) == ["user_id"])
    }

    @Test("Optional user fields may be missing or null", arguments: [
        #"{"user_id":"minimal"}"#,
        #"{"user_id":"minimal","email":null,"is_anonymous":null,"creation_date":null,"creation_version":null,"last_sign_in_date":null,"did_complete_onboarding":null,"profile_color_hex":null}"#
    ])
    func codable_decodesMinimalUser(json: String) throws {
        let user = try JSONDecoder().decode(UserModel.self, from: Data(json.utf8))

        #expect(user.userId == "minimal")
        #expect(user.email == nil)
        #expect(user.isAnonymous == nil)
        #expect(user.creationDate == nil)
        #expect(user.creationVersion == nil)
        #expect(user.lastSignInDate == nil)
        #expect(user.didCompleteOnboarding == nil)
        #expect(user.profileColorHex == nil)
    }

    @Test("Decoding rejects missing IDs and invalid boolean fields", arguments: [
        #"{}"#,
        #"{"user_id":null}"#,
        #"{"user_id":"user_123","is_anonymous":"false"}"#,
        #"{"user_id":"user_123","did_complete_onboarding":"true"}"#
    ])
    func codable_rejectsInvalidPayload(json: String) {
        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(UserModel.self, from: Data(json.utf8))
        }
    }

    @Test("Event parameters preserve false flags instead of omitting them")
    func asEventParameter_preservesFalseFlags() {
        let parameters = UserModel(userId: "user_123", isAnonymous: false, didCompleteOnboarding: false).asEventParameter

        #expect(Set(parameters.keys) == ["user_user_id", "user_is_anonymous", "user_did_complete_onboarding"])
        #expect(parameters["user_is_anonymous"] as? Bool == false)
        #expect(parameters["user_did_complete_onboarding"] as? Bool == false)
    }
}
