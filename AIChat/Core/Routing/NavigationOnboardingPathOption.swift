//
//  NavigationOnboardingPathOption.swift
//  AIChat
//
//  Created by Youssef Mohamed on 13/10/2026.
//

import Foundation
import SwiftUI

enum NavigationOnboardingPathOption: Hashable {
    case onboardingIntro
    case colorView
    case communityView
    case completedView(selectedColor: Color)
}
