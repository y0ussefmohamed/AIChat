//
//  MixpanelService.swift
//  AIChat
//
//  Created by Youssef Mohamed on 12/08/2026.
//

import Foundation
import Mixpanel

struct MixpanelService: LogService {

    private var instance: MixpanelInstance { Mixpanel.mainInstance() }

    init(token: String, loggingEnabled: Bool = false, serverURL: String = "https://api-eu.mixpanel.com") {
        Mixpanel.initialize(token: token, trackAutomaticEvents: true, serverURL: serverURL)
        instance.serverURL = serverURL
        instance.loggingEnabled = loggingEnabled
    }

    func identifyUser(userId: String, name: String?, email: String?) {
        instance.identify(distinctId: userId)

        if let name {
            instance.people.set(property: "$name", to: name)
        }

        if let email {
            instance.people.set(property: "$email", to: email)
        }
    }
    
    func addUserProperties(properties: [String: Any], isHighPriority: Bool) {
        var userProperties: [String: MixpanelType] = [:]
        for (key, value) in properties {
            let key = key.clipped(to: 255)
            if let value = value as? MixpanelType {
                userProperties[key] = value
            }
        }

        instance.people.set(properties: userProperties)
    }
    
    func deleteUserProfile() {
        instance.people.deleteUser()
        instance.reset()
    }
    
    func trackEvent(event: any LoggableEvent) {
        var eventProperties: [String: MixpanelType] = [:]

        if let params = event.parameters {
            for (key, value) in params {
                let key = key.clipped(to: 255)
                if let value = value as? MixpanelType {
                    eventProperties[key] = value
                }
            }
        }

        instance.track(event: event.eventName, properties: eventProperties.isEmpty ? nil : eventProperties)
        instance.flush()
    }
    
    func trackScreenEvent(event: any LoggableEvent) {
        trackEvent(event: event)
    }
}
