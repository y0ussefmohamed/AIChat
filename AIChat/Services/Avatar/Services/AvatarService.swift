//
//  AvatarService.swift
//  AIChat
//
//  Created by Youssef Mohamed on 16/04/2026.
//

import Foundation
import SwiftUI

protocol AvatarService {
    func createAvatar(avatar: Avatar, image: UIImage) async throws
}
