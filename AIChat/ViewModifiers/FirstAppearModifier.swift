//
//  FirstAppearModifier.swift
//  AIChat
//
//  Created by Youssef Mohamed on 16/04/2026.
//

import Foundation
import SwiftUI

struct FirstAppearModifier: ViewModifier {
    let action: () -> Void
    @State private var hasAppeared = false

    func body(content: Content) -> some View {
        content.onAppear {
            if !hasAppeared {
                action()
                hasAppeared = true
            }
        }
    }
}
