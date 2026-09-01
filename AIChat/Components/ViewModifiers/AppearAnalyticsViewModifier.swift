//
//  AppearAnalyticsViewModifier.swift
//  AIChat
//
//  Created by Youssef Mohamed on 01/09/2026.
//

import SwiftUI
import Foundation

struct AppearAnalyticsViewModifier: ViewModifier {
    @Environment(LogManager.self) private var logManager
    let viewName: String

    func body(content: Content) -> some View {
        content
            .onAppear {
                logManager.trackScreenEvent(event: AppearanceEvent.appear(screenName: viewName))
            }
            .onDisappear {
                logManager.trackScreenEvent(event: AppearanceEvent.disappear(screenName: viewName))
            }
    }

    enum AppearanceEvent: LoggableEvent {
        case appear(screenName: String), disappear(screenName: String)
        
        var type: LogType {
            .analytic
        }
        
        var eventName: String {
            switch self {
            case .appear(screenName: let screenName):
                return "\(screenName)_Appear"
            case .disappear(screenName: let screenName):
                return "\(screenName)_Disappear"
            }
        }
        
        var parameters: [String : Any]? {
            nil
        }
    }
}
