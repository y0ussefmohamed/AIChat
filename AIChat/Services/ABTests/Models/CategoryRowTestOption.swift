//
//  CategoryRowTestOption.swift
//  AIChat
//
//  Created by Youssef Mohamed on 01/10/2026.
//

import Foundation

enum CategoryRowTestOption: String, Codable, CaseIterable {
    case original, top, hidden

    static var `default`: Self {
        .original
    }
}

@propertyWrapper
struct EnumUserDefault<T: RawRepresentable> where T.RawValue == String {
    let key: String
    let startingValue: T

    var wrappedValue: T {
        get {
            guard
                let stringValue = UserDefaults.standard.string(forKey: key),
                let value = T(rawValue: stringValue)
            else {
                UserDefaults.standard.set(startingValue.rawValue, forKey: key)
                return startingValue
            }

            return value
        }

        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: key)
        }
    }
}
