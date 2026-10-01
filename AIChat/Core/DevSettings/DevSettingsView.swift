//
//  DevSettingsView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 04/08/2026.
//

import SwiftUI
import SwiftfulUtilities

struct DevSettingsView: View {
    @Environment(LogManager.self) private var logManager
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(ABTestManager.self) private var abTestManager

    @State private var createAccountTest: Bool = false
    @State private var onboardingCommunityTest: Bool = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Toggle("CreateAccountTest", isOn: $createAccountTest)
                        .onChange(of: createAccountTest) { _, newValue in
                            updateCreateAccountTest(to: newValue)
                        }

                    Toggle("OnboardingCommunityTest", isOn: $onboardingCommunityTest)
                        .onChange(of: onboardingCommunityTest) { _, newValue in
                            updateOnboardingCommunityTest(to: newValue)
                        }
                } header: {
                    Text("AB Test Section")
                }

                Section {
                    ForEach(authInfo, id: \.key) { item in
                        itemRow(item: item)
                    }
                } header: {
                    Text("Auth Info")
                }

                Section {
                    ForEach(currentUserInfo, id: \.key) { item in
                        itemRow(item: item)
                    }
                } header: {
                    Text("Current User Info")
                }

                Section {
                    ForEach(deviceInfo, id: \.key) { item in
                        itemRow(item: item)
                    }
                } header: {
                    Text("Device Info")
                }
            }
            .screenAppearAnalytics(viewName: "DevSettingsView")
            .navigationTitle("Dev Settings")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Image(systemName: "xmark")
                        .styledButton {
                            onCloseButtonPressed()
                        }
                }
            }
            .onFirstAppear {
                loadActiveTests()
            }
        }
    }
}

private extension DevSettingsView {
    var authInfo: [(key: String, value: Any)] {
        authManager.auth?.asEventParameter.asAlphabeticalString ?? []
    }

    var currentUserInfo: [(key: String, value: Any)] {
        userManager.currentUser?.asEventParameter.asAlphabeticalString ?? []
    }

    var deviceInfo: [(key: String, value: Any)] {
        Utilities.eventParameters.asAlphabeticalString
    }

    func loadActiveTests() {
        createAccountTest = abTestManager.activeTests.createAccountTest
        onboardingCommunityTest = abTestManager.activeTests.onboardingCommunityTest
    }

    func updateCreateAccountTest(to newValue: Bool) {
        guard newValue != abTestManager.activeTests.createAccountTest else {
            return
        }

        /// since activeTests is a get only property
        var tests = abTestManager.activeTests
        tests.update(createAccountTest: newValue)

        try? abTestManager.override(updatedTests: tests)
    }

    func updateOnboardingCommunityTest(to newValue: Bool) {
        guard newValue != abTestManager.activeTests.onboardingCommunityTest else {
            return
        }

        var tests = abTestManager.activeTests
        tests.update(onboardingCommunityTest: newValue)

        try? abTestManager.override(updatedTests: tests)
    }

    func onCloseButtonPressed() {
        logManager.trackEvent(event: DevSettingsViewEvent.closeButtonPressed)
        dismiss()
    }

    func itemRow(item: (key: String, value: Any)) -> some View {
        HStack {
            Text(item.key)

            Spacer()

            if let value = item.value as? String {
                if value.hasPrefix("#"),
                   let color = Color(hex: value) {
                    Circle()
                        .fill(color)
                        .frame(width: 24, height: 24)
                } else if let convertedValue = String.convertToString(item.value) {
                    Text(convertedValue)
                }
            }
        }
    }
}

extension DevSettingsView {
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

#Preview {
    DevSettingsView()
        .environment(LogManager(services: [ConsoleService()]))
        .previewEnvironment()
}
