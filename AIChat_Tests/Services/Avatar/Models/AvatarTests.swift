import Foundation
import Testing
@testable import AIChat

@MainActor
struct AvatarTests {

    @Test("Initializing with only an ID leaves optional avatar fields nil")
    func init_withDefaultValues_setsPropertiesCorrectly() {
        let avatar = Avatar(avatarId: "avatar_123")

        #expect(avatar.id == "avatar_123")
        #expect(avatar.avatarId == "avatar_123")
        #expect(avatar.name == nil)
        #expect(avatar.characterOption == nil)
        #expect(avatar.characterAction == nil)
        #expect(avatar.characterLocation == nil)
        #expect(avatar.profileImageName == nil)
        #expect(avatar.authorId == nil)
        #expect(avatar.dateCreated == nil)
        #expect(avatar.clickCount == nil)
    }

    @Test("Character description combines all attributes with the appropriate article")
    func characterDescription_withCompleteAttributes_formatsDescription() {
        let alien = Avatar(avatarId: "alien", characterOption: .alien, characterAction: .smiling, characterLocation: .park)
        let dog = Avatar(avatarId: "dog", characterOption: .dog, characterAction: .walking, characterLocation: .forest)

        #expect(alien.characterDescription == "An alien that is smiling in the park.")
        #expect(dog.characterDescription == "A dog that is walking in the forest.")
    }

    @Test("Character description is nil when any required attribute is missing")
    func characterDescription_withMissingAttributes_returnsNil() {
        let avatars = [
            Avatar(avatarId: "missing_option", characterAction: .smiling, characterLocation: .park),
            Avatar(avatarId: "missing_action", characterOption: .alien, characterLocation: .park),
            Avatar(avatarId: "missing_location", characterOption: .alien, characterAction: .smiling),
            Avatar(avatarId: "missing_all")
        ]

        for avatar in avatars {
            #expect(avatar.characterDescription == nil)
        }
    }

    @Test("Updating the profile image preserves all other fields and the original value copy")
    func updateProfileImage_changesOnlyImage() {
        let original = makeAvatar()
        var updated = original

        updated.updateProfileImage(withName: "new_image.png")

        #expect(updated.profileImageName == "new_image.png")
        #expect(original.profileImageName == "avatar.png")
        let expected = Avatar(
            avatarId: original.avatarId, name: original.name,
            characterOption: original.characterOption, characterAction: original.characterAction,
            characterLocation: original.characterLocation, profileImageName: "new_image.png",
            authorId: original.authorId, dateCreated: original.dateCreated, clickCount: original.clickCount
        )
        #expect(updated == expected)
    }

    @Test("New avatars receive unique UUIDs, creation dates, and initial values")
    func newAvatar_setsCreationDefaults() throws {
        let before = Date()
        let avatar = Avatar.newAvatar(name: "Alpha", option: .alien, action: .smiling, location: .park, authorId: "user_123")
        let second = Avatar.newAvatar(name: "Alpha", option: .alien, action: .smiling, location: .park, authorId: "user_123")
        let after = Date()
        let dateCreated = try #require(avatar.dateCreated)

        #expect(UUID(uuidString: avatar.avatarId) != nil)
        #expect(avatar.avatarId != second.avatarId)
        #expect(avatar.id == avatar.avatarId)
        #expect(avatar.name == "Alpha")
        #expect(avatar.characterOption == .alien)
        #expect(avatar.characterAction == .smiling)
        #expect(avatar.characterLocation == .park)
        #expect(avatar.authorId == "user_123")
        #expect(avatar.profileImageName == nil)
        #expect(avatar.clickCount == 0)
        #expect(dateCreated >= before)
        #expect(dateCreated <= after)
    }

    @Test("Event parameters omit nil fields and preserve nested character attributes")
    func asEventParameter_containsExpectedKeysAndValues() throws {
        let minimal = Avatar(avatarId: "minimal").asEventParameter
        #expect(Set(minimal.keys) == ["avatar_avatar_id"])
        #expect(minimal["avatar_avatar_id"] as? String == "minimal")

        let avatar = makeAvatar()
        let parameters = avatar.asEventParameter
        #expect(Set(parameters.keys) == [
            "avatar_avatar_id", "avatar_name", "avatar_character_option", "avatar_character_action",
            "avatar_character_location", "avatar_profile_image_name", "avatar_author_id",
            "avatar_date_created", "avatar_click_count"
        ])
        #expect(parameters["avatar_avatar_id"] as? String == "avatar_123")
        #expect(parameters["avatar_name"] as? String == "Alpha")
        let option = try #require(parameters["avatar_character_option"] as? [String: Any])
        let action = try #require(parameters["avatar_character_action"] as? [String: Any])
        let location = try #require(parameters["avatar_character_location"] as? [String: Any])
        #expect(option["character_option"] as? String == "alien")
        #expect(action["character_action"] as? String == "smiling")
        #expect(location["character_location"] as? String == "park")
        #expect(parameters["avatar_profile_image_name"] as? String == "avatar.png")
        #expect(parameters["avatar_author_id"] as? String == "user_123")
        #expect(parameters["avatar_date_created"] as? Date == avatar.dateCreated)
        #expect(parameters["avatar_click_count"] as? Int == 0)
    }

    @Test("Codable round trip preserves every avatar field")
    func codable_encodesAndDecodesSuccessfully() throws {
        let original = makeAvatar()
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Avatar.self, from: data)

        #expect(decoded == original)
    }

    @Test("Encoding uses the persisted snake_case schema")
    func codable_encodesExpectedKeys() throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        let data = try encoder.encode(makeAvatar())
        let json = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])

        #expect(Set(json.keys) == [
            "avatar_id", "name", "character_option", "character_action", "character_location",
            "profile_image_name", "author_id", "date_created", "click_count"
        ])
        #expect(json["character_option"] as? String == "alien")
        #expect(json["character_action"] as? String == "smiling")
        #expect(json["character_location"] as? String == "park")
        #expect(json["date_created"] as? Double == 1_700_000_000)
    }

    @Test("Decoding a persisted avatar maps every field")
    func codable_decodesFromCustomCodingKeysJSON() throws {
        let data = Data("""
        {"avatar_id":"avatar_123","name":"Alpha","character_option":"alien",
         "character_action":"smiling","character_location":"park","profile_image_name":"avatar.png",
         "author_id":"user_123","date_created":1700000000,"click_count":0}
        """.utf8)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970

        #expect(try decoder.decode(Avatar.self, from: data) == makeAvatar())
    }

    @Test("Missing and null optional fields decode as nil", arguments: [
        #"{"avatar_id":"minimal"}"#,
        #"{"avatar_id":"minimal","name":null,"character_option":null,"character_action":null,"character_location":null,"profile_image_name":null,"author_id":null,"date_created":null,"click_count":null}"#
    ])
    func codable_decodesMinimalAvatar(json: String) throws {
        let decoded = try JSONDecoder().decode(Avatar.self, from: Data(json.utf8))

        #expect(decoded == Avatar(avatarId: "minimal"))
    }

    @Test("Decoding rejects a missing avatar ID and invalid field types", arguments: [
        #"{}"#,
        #"{"avatar_id":null}"#,
        #"{"avatar_id":"avatar_123","click_count":"many"}"#
    ])
    func codable_rejectsInvalidPayload(json: String) {
        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(Avatar.self, from: Data(json.utf8))
        }
    }

    @Test("Equal avatars deduplicate in a set and changed fields distinguish values")
    func hashable_comparesCompleteValues() {
        let original = makeAvatar()
        let identical = makeAvatar()
        var changed = original
        changed.updateProfileImage(withName: "different.png")

        #expect(original == identical)
        #expect(original != changed)
        #expect(Set([original, identical, changed]).count == 2)
    }

    private func makeAvatar() -> Avatar {
        Avatar(
            avatarId: "avatar_123", name: "Alpha", characterOption: .alien,
            characterAction: .smiling, characterLocation: .park, profileImageName: "avatar.png",
            authorId: "user_123", dateCreated: Date(timeIntervalSince1970: 1_700_000_000), clickCount: 0
        )
    }
}
