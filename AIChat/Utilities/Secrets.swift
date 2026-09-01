import Foundation

enum Secrets {
    static func value(for key: String) -> String {
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path),
              let value = dict[key] as? String else {
            fatalError("Missing secret: \(key)")
        }
        return value
    }

    static var groqAPIKey: String { value(for: "GROQ_API_KEY") }
    static var mixpanelToken: String { value(for: "MIXPANEL_TOKEN") }
}
