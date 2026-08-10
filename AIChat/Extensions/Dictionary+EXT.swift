//
//  Dictionary+EXT.swift
//  AIChat
//
//  Created by Youssef Mohamed on 04/08/2026.
//

import Foundation

extension Dictionary where Key == String, Value == Any {
    var asAlphabeticalString: [(key: String, value: Any)] {
        self.map { ($0, $1) }.sorted(by: { $0.key < $1.key })
    }
}

extension Dictionary where Key == String {
    mutating func first(upTo maxItems: Int) {
        var counter = 0
        for (key, _) in self {
            if counter >= maxItems {
                removeValue(forKey: key)
            } else {
                counter += 1
            }
        }
    }
}
