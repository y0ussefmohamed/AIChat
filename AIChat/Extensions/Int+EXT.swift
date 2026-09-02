//
//  Int+EXT.swift
//  AIChat
//
//  Created by Youssef Mohamed on 02/09/2026.
//

import Foundation

extension Int {
    func asEventParameter(key: String = "count") -> [String: Any] {
        [key: self]
    }
}
