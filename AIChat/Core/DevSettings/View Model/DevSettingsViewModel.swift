//
//  DevSettingsViewModel.swift
//  AIChat
//
//  Created by Youssef Mohamed on 04/08/2026.
//

import SwiftUI
import SwiftfulUtilities

@MainActor
@Observable
class DevSettingsViewModel {
    private let interactor: DevSettingsInteractor

    var createAccountTest: Bool = false
    var onboardingCommunityTest: Bool = false
    var categoryRowTest: CategoryRowTestOption = .default
    var alert: AnyAppAlert?

    init (interactor: DevSettingsInteractor) {
        self.interactor = interactor
    }

    var canOverrideTests: Bool {
        interactor.canOverrideTests
    }


    var authInfo: [(key: String, value: Any)] {
        interactor.auth?.asEventParameter.asAlphabeticalString ?? []
    }

    var currentUserInfo: [(key: String, value: Any)] {
        interactor.currentUser?.asEventParameter.asAlphabeticalString ?? []
    }

    var deviceInfo: [(key: String, value: Any)] {
        Utilities.eventParameters.asAlphabeticalString
    }

    func loadActiveTests() {
        createAccountTest = interactor.activeTests.createAccountTest
        onboardingCommunityTest = interactor.activeTests.onboardingCommunityTest
        categoryRowTest = interactor.activeTests.categoryRowTest
    }

    func updateCreateAccountTest(to newValue: Bool) {
        guard newValue != interactor.activeTests.createAccountTest else {
            return
        }

        /// since activeTests is a get only property
        var tests = interactor.activeTests
        tests.update(createAccountTest: newValue)

        do {
            try interactor.override(updatedTests: tests)
        } catch {
            loadActiveTests()
            alert = AnyAppAlert(error: error)
        }
    }

    func updateOnboardingCommunityTest(to newValue: Bool) {
        guard newValue != interactor.activeTests.onboardingCommunityTest else {
            return
        }

        var tests = interactor.activeTests
        tests.update(onboardingCommunityTest: newValue)

        do {
            try interactor.override(updatedTests: tests)
        } catch {
            loadActiveTests()
            alert = AnyAppAlert(error: error)
        }
    }

    func updateCategoryRowTest(to newValue: CategoryRowTestOption) {
        guard newValue != interactor.activeTests.categoryRowTest else {
            return
        }

        var tests = interactor.activeTests
        tests.update(categoryRowTest: newValue)

        do {
            try interactor.override(updatedTests: tests)
        } catch {
            loadActiveTests()
            alert = AnyAppAlert(error: error)
        }
    }

    func onCloseButtonPressed(onDismiss dismiss: @escaping () -> Void) {
        interactor.trackEvent(event: DevSettingsViewEvent.closeButtonPressed)
        dismiss()
    }
}

extension DevSettingsViewModel {
    enum DevSettingsViewEvent: LoggableEvent {
        case closeButtonPressed

        var eventName: String {
            switch self {
            case .closeButtonPressed:
                return "DevSettingsView_Close_Pressed"
            }
        }

        var parameters: [String: Any]? {
            nil
        }

        var type: LogType {
            .analytic
        }
    }
}
