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
