//
//  SettingsView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 04/03/2026.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState

    var body: some View {
        NavigationStack {
            List {
                Button(action: onSignOutPressed) {
                    Text("Sign out")
                }
            }
            .navigationTitle("Settings")
        }
    }
}

// MARK: - Seperate Business Logic out of Views
extension SettingsView {
    private func onSignOutPressed() {
        Task {
            dismiss()
            try? await Task.sleep(for: .seconds(0.25))
            appState.updateViewState(showTabBar: false)
        }
    }
}

#Preview {
    SettingsView()
        .environment(AppState())
}
