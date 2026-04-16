//
//  Collection+EXT.swift
//  AIChat
//
//  Created by Youssef Mohamed on 16/04/2026.
//

extension Collection {
    func choose(_ n: Int) -> [Element] {
        return Array(shuffled().prefix(n))
    }
}
