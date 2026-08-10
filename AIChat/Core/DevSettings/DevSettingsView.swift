//
//  DevSettingsView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 04/08/2026.
//

import SwiftUI
import SwiftfulUtilities

struct DevSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager

    var body: some View {
        NavigationStack {
            List {
                Section {
                    let authArray = authManager.auth?.eventParameters.asAlphabeticalString ?? []

                    ForEach(authArray, id: \.key) { item in
                        itemRow(item: item)
                    }
                } header: {
                    Text("Auth Info")
                }

                Section {
                    let userArray = userManager.currentUser?.eventParameters.asAlphabeticalString ?? []

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
            .navigationTitle("Dev Settings")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Image(systemName: "xmark")
                        .styledButton {
                            dismiss()
                        }
                }
            }
        }
    }
}

extension DevSettingsView {
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

#Preview {
    DevSettingsView()
        .previewEnvironment()
}
