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

    var body: some View {
        NavigationStack {
            List {
                Section {
                    let authArray = authManager.auth?.asEventParameter.asAlphabeticalString ?? []

                    ForEach(authArray, id: \.key) { item in
                        itemRow(item: item)
                    }
                } header: {
                    Text("Auth Info")
                }

                Section {
                    let userArray = userManager.currentUser?.asEventParameter.asAlphabeticalString ?? []

                    ForEach(userArray, id: \.key) { item in
                        itemRow(item: item)
                    }
                } header: {
                    Text("Current User Info")
                }

                Section {
                    let deviceInfoArray = Utilities.eventParameters.asAlphabeticalString

                    ForEach(deviceInfoArray, id: \.key) { item in
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
        }
    }
}

extension DevSettingsView {
    private func onCloseButtonPressed() {
        logManager.trackEvent(event: DevSettingsViewEvent.closeButtonPressed)
        dismiss()
    }

    private func itemRow(item: (key: String, value: Any)) -> some View {
        HStack {
            Text(item.key)

            Spacer()

            if let value = item.value as? String {
                if value.hasPrefix("#"),
                   let color = Color(hex: value) {
                    Circle()
                        .fill(color)
                        .frame(width: 24, height: 24)
                } else {
                    if let conv = String.convertToString(item.value) {
                        Text(conv)
                    }
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
