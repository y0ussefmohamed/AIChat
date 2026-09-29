//
//  UserDefaultsPropertyWrapper.swift
//  AIChat
//
//  Created by Youssef Mohamed on 29/09/2026.
//

import Foundation

protocol UserDefaultsCompatible {}
extension Bool: UserDefaultsCompatible {}
extension Int: UserDefaultsCompatible {}
extension Float: UserDefaultsCompatible {}
extension Double: UserDefaultsCompatible {}
extension String: UserDefaultsCompatible {}
extension URL: UserDefaultsCompatible {}

/// this `wrapper` is used to set this `Bool` to `.random()` if not saved in `UserDefaults` and if saved then extract the saved value
@propertyWrapper
struct UserDefault<T: UserDefaultsCompatible> {
    let key: String
    let startingValue: T

    init(key: String, startingValue: T) {
        self.key = key
        self.startingValue = startingValue
    }

    var wrappedValue: T {
        get {
            if let savedValue = UserDefaults.standard.value(forKey: key) as? T {
                return savedValue
            } else {
                UserDefaults.standard.setValue(startingValue, forKey: key)
                return startingValue
            }
        }

        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}
