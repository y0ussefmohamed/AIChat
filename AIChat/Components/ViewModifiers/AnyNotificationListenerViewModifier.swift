//
//  AnyNotificationListenerViewModifier.swift
//  AIChat
//
//  Created by Youssef Mohamed on 13/09/2026.
//

import Foundation
import SwiftUI

struct AnyNotificationListenerViewModifier: ViewModifier {
    let notificationName: Notification.Name
    let action: @MainActor (Notification) -> Void

    func body(content: Content) -> some View {
        content
            /// `App Lifecycle stuff`
            .onReceive(NotificationCenter.default.publisher(for: notificationName)) { notification in
                action(notification)
            }
    }
}

extension View {
    func onNotificationReceived(notificationName: Notification.Name, action: @MainActor @escaping (Notification) -> Void) -> some View {
        self
            .modifier(AnyNotificationListenerViewModifier(notificationName: notificationName, action: action))
    }
}
