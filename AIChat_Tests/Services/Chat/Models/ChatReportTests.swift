import Foundation
import Testing
@testable import AIChat

@MainActor
struct ChatReportTests {

    @Test("Reports preserve an explicitly supplied ID and creation date")
    func init_withExplicitValues_setsPropertiesCorrectly() {
        let report = makeReport()

        #expect(report.id == "report_123")
        #expect(report.chatId == "chat_123")
        #expect(report.userId == "user_123")
        #expect(report.dateCreated == Date(timeIntervalSince1970: 1_700_000_000))
    }

    @Test("Reports generate unique UUIDs and current creation dates by default")
    func init_withDefaultValues_generatesIDAndDate() {
        let before = Date()
        let first = ChatReport(chatId: "chat_123", userId: "user_123")
        let second = ChatReport(chatId: "chat_123", userId: "user_123")
        let after = Date()

        #expect(first.chatId == "chat_123")
        #expect(first.userId == "user_123")
        #expect(UUID(uuidString: first.id) != nil)
        #expect(UUID(uuidString: second.id) != nil)
        #expect(first.id != second.id)
        #expect(first.dateCreated >= before)
        #expect(first.dateCreated <= after)
        #expect(second.dateCreated >= before)
        #expect(second.dateCreated <= after)
    }

    @Test("Codable round trip preserves every report field")
    func codable_encodesAndDecodesSuccessfully() throws {
        let original = makeReport()
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ChatReport.self, from: data)

        #expect(decoded.id == original.id)
        #expect(decoded.chatId == original.chatId)
        #expect(decoded.userId == original.userId)
        #expect(decoded.dateCreated == original.dateCreated)
    }

    @Test("Encoding uses snake_case report keys")
    func codable_encodesExpectedKeys() throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        let data = try encoder.encode(makeReport())
        let json = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])

        #expect(Set(json.keys) == ["id", "chat_id", "user_id", "date_created"])
        #expect(json["id"] as? String == "report_123")
        #expect(json["chat_id"] as? String == "chat_123")
        #expect(json["user_id"] as? String == "user_123")
        #expect(json["date_created"] as? Double == 1_700_000_000)
    }

    @Test("Decoding persisted reports maps all custom coding keys")
    func codable_decodesFromCustomCodingKeysJSON() throws {
        let data = Data("""
        {"id":"report_123","chat_id":"chat_123","user_id":"user_123","date_created":1700000000}
        """.utf8)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        let report = try decoder.decode(ChatReport.self, from: data)

        #expect(report.id == "report_123")
        #expect(report.chatId == "chat_123")
        #expect(report.userId == "user_123")
        #expect(report.dateCreated == Date(timeIntervalSince1970: 1_700_000_000))
    }

    @Test("Decoding requires all report fields despite initializer defaults", arguments: ["id", "chat_id", "user_id", "date_created"])
    func codable_rejectsMissingRequiredField(key: String) throws {
        var json: [String: Any] = [
            "id": "report_123", "chat_id": "chat_123", "user_id": "user_123", "date_created": 1_700_000_000
        ]
        json.removeValue(forKey: key)
        let data = try JSONSerialization.data(withJSONObject: json)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970

        #expect(throws: DecodingError.self) {
            try decoder.decode(ChatReport.self, from: data)
        }
    }

    private func makeReport() -> ChatReport {
        ChatReport(id: "report_123", chatId: "chat_123", userId: "user_123", dateCreated: Date(timeIntervalSince1970: 1_700_000_000))
    }
}
