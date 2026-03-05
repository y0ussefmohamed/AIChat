//
//  ProfileView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 04/03/2026.
//

import SwiftUI

struct ProfileView: View {
    @State private var showSettingsView: Bool = false

    var body: some View {
        NavigationStack {
            Text("Profile")
                .navigationTitle("Profile")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        settingsButton
                    }
                }
        }
        .sheet(isPresented: $showSettingsView) {
            SettingsView()
        }
    }

    private var settingsButton: some View {
        Button(action: onSettingsButtonPressed) {
            Image(systemName: "gear")
        }
    }
}

// MARK: - Seperate Business Logic out of Views
extension ProfileView {
    private func onSettingsButtonPressed() {
        showSettingsView = true
    }
}

#Preview {
    ProfileView()
}
