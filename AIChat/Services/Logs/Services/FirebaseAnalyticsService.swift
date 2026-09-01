//
//  FirebaseAnalyticsService.swift
//  AIChat
//
//  Created by Youssef Mohamed on 08/08/2026.
//

import Foundation
import FirebaseAnalytics

struct FirebaseAnalyticsService: LogService {

    func identifyUser(userId: String, name: String?, email: String?) {
        Analytics.setUserID(userId)

        if let name {
            Analytics.setUserProperty(name, forName: "account_name")
        }
        if let email {
            Analytics.setUserProperty(email, forName: "account_email")
        }
    }
    
    func addUserProperties(properties: [String: Any], isHighPriority: Bool) {
        guard isHighPriority else { return }

        for (key, value) in properties {
            if let stringValue = String.convertToString(value) {
                let key = key.clean(to: 40), stringValue = stringValue.clean(to: 100)

                Analytics.setUserProperty(stringValue, forName: key)
            }
        }
    }
    
    func deleteUserProfile() {
        Analytics.setUserID(nil)
    }
    
    func trackEvent(event: any LoggableEvent) {
        guard event.type != .info else { return }

        var params = event.parameters ?? [:]

        /// convert other types of `value` into a string
        for (key, value) in params {
            if let dateVal = value as? Date, let strDateVal = String.convertToString(dateVal) {
                params[key] = String.convertToString(strDateVal)
            } else if let array = value as? [Any] {
                if let strArray = String.convertToString(array) {
                    params[key] = String.convertToString(strArray)
                } else {
                    params[key] = nil
                }
            }
        }

        /// fix key/value length limits
        for (key, value) in params {
            var newKey = key
            if key.count > 40 {
                params.removeValue(forKey: key)
                newKey = key.clean(to: 40)
                params[newKey] = value
            }

            if let strValue = value as? String {
                params[newKey] = strValue.clean(to: 100)
            }
        }

        params.first(upTo: 25)
        let eventName = event.eventName.clean(to: 40)
        Analytics.logEvent(eventName, parameters: params.isEmpty ? nil : params)
    }
    
    func trackScreenEvent(event: any LoggableEvent) {
        let eventName = event.eventName.clean(to: 40)

        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: eventName
        ])
    }
}
