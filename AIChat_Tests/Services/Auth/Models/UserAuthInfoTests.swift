import Foundation
import Testing
@testable import AIChat

@MainActor
struct UserAuthInfoTests {

    @Test("Default auth info is non-anonymous with nil optional fields")
    func init_withDefaultValues_setsPropertiesCorrectly() {
        let auth = UserAuthInfo(uid: "user_123")

        #expect(auth.uid == "user_123")
        #expect(auth.email == nil)
        #expect(auth.isAnonymous == false)
        #expect(auth.creationDate == nil)
        #expect(auth.lastSignInDate == nil)
    }

    @Test("Event parameters use auth prefixes, omit nil values, and preserve false")
    func asEventParameter_containsExpectedKeysAndValues() {
        let minimal = UserAuthInfo(uid: "minimal").asEventParameter
        #expect(Set(minimal.keys) == ["uauth_uid", "uauth_is_anonymous"])
        #expect(minimal["uauth_uid"] as? String == "minimal")
        #expect(minimal["uauth_is_anonymous"] as? Bool == false)

        let auth = makeAuth()
        let parameters = auth.asEventParameter
        #expect(Set(parameters.keys) == ["uauth_uid", "uauth_email", "uauth_is_anonymous", "uauth_creation_date", "uauth_last_sign_in_date"])
        #expect(parameters["uauth_uid"] as? String == "user_123")
        #expect(parameters["uauth_email"] as? String == "auth@example.com")
        #expect(parameters["uauth_is_anonymous"] as? Bool == true)
        #expect(parameters["uauth_creation_date"] as? Date == auth.creationDate)
        #expect(parameters["uauth_last_sign_in_date"] as? Date == auth.lastSignInDate)
    }

    @Test("Codable round trip preserves every authentication field")
    func codable_encodesAndDecodesSuccessfully() throws {
        let original = makeAuth()
        let data = try JSONEncoder().encode(original)

        #expect(try JSONDecoder().decode(UserAuthInfo.self, from: data) == original)
    }

    @Test("Encoding uses snake_case keys and omits nil fields")
    func codable_encodesExpectedKeys() throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        let data = try encoder.encode(makeAuth())
        let json = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])

        #expect(Set(json.keys) == ["uid", "email", "is_anonymous", "creation_date", "last_sign_in_date"])
        #expect(json["uid"] as? String == "user_123")
        #expect(json["email"] as? String == "auth@example.com")
        #expect(json["is_anonymous"] as? Bool == true)
        #expect(json["creation_date"] as? Double == 1_700_000_000)
        #expect(json["last_sign_in_date"] as? Double == 1_700_000_500)

        let minimalData = try encoder.encode(UserAuthInfo(uid: "minimal"))
        let minimalJSON = try #require(JSONSerialization.jsonObject(with: minimalData) as? [String: Any])
        #expect(Set(minimalJSON.keys) == ["uid", "is_anonymous"])
    }

    @Test("Decoding from snake_case JSON maps authentication fields")
    func codable_decodesFromCustomCodingKeysJSON() throws {
        let data = Data("""
        {"uid":"user_123","email":"auth@example.com","is_anonymous":true,
         "creation_date":1700000000,"last_sign_in_date":1700000500}
        """.utf8)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970

        #expect(try decoder.decode(UserAuthInfo.self, from: data) == makeAuth())
    }

    @Test("Optional auth fields may be missing or null", arguments: [
        #"{"uid":"minimal","is_anonymous":false}"#,
        #"{"uid":"minimal","is_anonymous":false,"email":null,"creation_date":null,"last_sign_in_date":null}"#
    ])
    func codable_decodesMinimalAuth(json: String) throws {
        let decoded = try JSONDecoder().decode(UserAuthInfo.self, from: Data(json.utf8))

        #expect(decoded == UserAuthInfo(uid: "minimal"))
    }

    @Test("Decoding requires the UID and anonymous status and rejects invalid types", arguments: [
        #"{"is_anonymous":false}"#,
        #"{"uid":"user_123"}"#,
        #"{"uid":null,"is_anonymous":false}"#,
        #"{"uid":"user_123","is_anonymous":"false"}"#
    ])
    func codable_rejectsInvalidPayload(json: String) {
        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(UserAuthInfo.self, from: Data(json.utf8))
        }
    }

    @Test("Equality includes every authentication field")
    func equatable_comparesAllProperties() {
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let original = UserAuthInfo(uid: "user_123", email: "auth@example.com", isAnonymous: true, creationDate: date, lastSignInDate: date)
        let identical = UserAuthInfo(uid: "user_123", email: "auth@example.com", isAnonymous: true, creationDate: date, lastSignInDate: date)
        let different = [
            UserAuthInfo(uid: "other", email: "auth@example.com", isAnonymous: true, creationDate: date, lastSignInDate: date),
            UserAuthInfo(uid: "user_123", email: nil, isAnonymous: true, creationDate: date, lastSignInDate: date),
            UserAuthInfo(uid: "user_123", email: "auth@example.com", isAnonymous: false, creationDate: date, lastSignInDate: date),
            UserAuthInfo(uid: "user_123", email: "auth@example.com", isAnonymous: true, creationDate: nil, lastSignInDate: date),
            UserAuthInfo(uid: "user_123", email: "auth@example.com", isAnonymous: true, creationDate: date, lastSignInDate: nil)
        ]

        #expect(original == identical)
        for auth in different {
            #expect(original != auth)
        }
    }

    private func makeAuth() -> UserAuthInfo {
        UserAuthInfo(
            uid: "user_123", email: "auth@example.com", isAnonymous: true,
            creationDate: Date(timeIntervalSince1970: 1_700_000_000),
            lastSignInDate: Date(timeIntervalSince1970: 1_700_000_500)
        )
    }
}
