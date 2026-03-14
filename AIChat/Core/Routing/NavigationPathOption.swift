//
//  NavigationPathOption.swift
//  AIChat
//
//  Created by Youssef Mohamed on 15/03/2026.
//

import Foundation

enum NavigationPathOption: Hashable {
    case chat(String) /// avatarId
    case category(CharacterOption, String) /// category, imageName
}
