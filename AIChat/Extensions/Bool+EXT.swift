//
//  Bool+EXT.swift
//  AIChat
//
//  Created by Youssef Mohamed on 02/09/2026.
//

import Foundation

extension Bool {
    func asEventParameter(key: String = "value") -> [String: Any] {
        switch self {
        case true:
            return [key: true]
        case false:
            return [key: false]
        }
    }
}
