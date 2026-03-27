//
//  AnyAppAlert.swift
//  AIChat
//
//  Created by Youssef Mohamed on 27/03/2026.
//

import Foundation
import SwiftUI

extension Binding where Value == Bool {
    /// `T: Sendable` ; because the alert that will be passed here should be `Sendable`
    init<T: Sendable>(ifNotNil value: Binding<T?>) {
        self.init {
            /// listens to the changes whether the alert is currently nil or not nil
            value.wrappedValue != nil /// binding is true when the alert is not nil (has been set to something in the file/app)
        } set: { newValue in
            if !newValue { /// if newValue == false this means there is no alert now so reset it back to nil (to be false in the getter above)
                value.wrappedValue = nil
            }
        }
    }
}

struct AnyAppAlert: Sendable { /// `Sendable` is used here to move the alert from background to main thread safely
    var title: String /// `String` value type is safe
    var subtitle: String?
    var buttons: @Sendable () -> AnyView /// `Refrence Type` is not safe so we should use @Sendable

    init(title: String, subtitle: String? = nil, buttons: (@Sendable () -> AnyView)? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.buttons = buttons ?? { AnyView(Button("OK") {}) }
    }

    init(error: Error) {
        self.init(title: "Error", subtitle: error.localizedDescription, buttons: nil)
    }
}
