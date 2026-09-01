//
//  FirebaseCrashlyticService.swift
//  AIChat
//
//  Created by Youssef Mohamed on 01/09/2026.
//

import Foundation
import FirebaseCrashlytics

struct FirebaseCrashlyticsService: LogService {
    
    func identifyUser(userId: String, name: String?, email: String?) {
        Crashlytics.crashlytics().setUserID(userId)

        if let name {
            Crashlytics.crashlytics().setCustomValue(name, forKey: "account_name")
        }

        if let email {
            Crashlytics.crashlytics().setCustomValue(email, forKey: "account_email")
        }
    }
    
    func addUserProperties(properties: [String: Any], isHighPriority: Bool) {
        guard isHighPriority else { return }

        for (key, value) in properties {
            Crashlytics.crashlytics().setCustomValue(value, forKey: key)
        }
    }
    
    func deleteUserProfile() {
        Crashlytics.crashlytics().setUserID("new")
    }
    
    func trackEvent(event: any LoggableEvent) {
        guard event.type != .info else { return }

        switch event.type {
        case .info, .analytic:
            break
        case .warning, .severe:
            let error = NSError(
                domain: event.eventName,
                code: event.eventName.stableHashValue,
                userInfo: event.parameters
            )

            Crashlytics.crashlytics().record(error: error, userInfo: event.parameters)
        }
    }
    
    func trackScreenEvent(event: any LoggableEvent) {
        trackEvent(event: event)
    }
}
