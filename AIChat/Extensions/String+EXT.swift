//
//  String+EXT.swift
//  AIChat
//
//  Created by Youssef Mohamed on 10/08/2026.
//

import Foundation

extension String {
    static func convertToString(_ value: Any) -> String? {
        switch value {
        case let value as String:
            return value
        case let value as Int:
            return "\(value)"
        case let value as Double:
            return "\(value)"
        case let value as Float:
            return "\(value)"
        case let value as Bool:
            return "\(value)"
        case let value as Date:
            return value.formatted(date: .abbreviated, time: .shortened)
        case let array as [Any]:
            return array.compactMap({String.convertToString($0)}).sorted().joined(separator: ", ")
        case let value as CustomStringConvertible:
            return value.description
        default:
            return nil
        }
    }

    func clean(to length: Int) -> String {
        self
            .clipped(to: length)
            .replaceSpacesWithUnderscores()
    }

    func clipped(to length: Int) -> String {
        return String(prefix(length))
    }

    func replaceSpacesWithUnderscores() -> String {
        self.replacingOccurrences(of: " ", with: "_")
    }

    var stableHashValue: Int {
        let unicodeScalars = self.unicodeScalars.map { $0.value }
        return unicodeScalars.reduce(5381) { ($0 << 5) &+ $0 &+ Int($1) }
    }

    func asEventParameter(key: String) -> [String: Any] {
        [key: self]
    }
}
