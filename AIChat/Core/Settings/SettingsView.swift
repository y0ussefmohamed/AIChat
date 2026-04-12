//
//  SettingsView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 04/03/2026.
//

import SwiftUI
import SwiftfulUtilities

struct TextWidthPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct SettingsView: View {
    @Environment(\.authServices) private var authServices
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var isPremium: Bool = true
    @State private var isAnonymousUser: Bool = false
    @State private var versionTextWidth: CGFloat = 0
    @State private var showCreateAccountView: Bool = false
    @State private var showAlert: AnyAppAlert?

    var body: some View {
        NavigationStack {
            List {
                accountSection

                purchasesSection

                applicationSection

                aboutSection
                    .offset(y: -5)
            }
            .showCustomAlert(alert: $showAlert)
            .sheet(isPresented: $showCreateAccountView, onDismiss: {
                setAnonymousAccountStatus()
            }, content: {
                LinkProviderView(usageOption: .createAccount)
            })
            .navigationTitle("Settings")
            .onAppear {
                setAnonymousAccountStatus()
            }
        }
    }

    private var accountSection: some View {
        Section {
            if isAnonymousUser {
                Text("Save & Backup Account")
                    .styledButton(.plain, action: onCreateAccountPressed)
            } else {
                if authServices.getAuthenticatedUser() == nil {
                    Text("No User Account Exists")
                } else {
                    Text("Sign out")
                        .styledButton(.plain, action: onSignOutPressed)
                }
            }

            Text("Delete Account")
                .foregroundStyle(.red)
                .styledButton(.plain) {
                    onDeleteAccountPressed()
                }
        } header: {
            Text("Account")
        }
    }

    private var purchasesSection: some View {
        Section {
            HStack {
                Text("Account Status: \(premiumStatus)")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .styledButton(.plain) {

                    }

                if isPremium {
                    Text("Manage")
                        .badgeButtonModifier()
                        .styledButton(.pressable) {

                        }
                }
            }

        } header: {
            Text("Purchases")
        }
    }

    private var applicationSection: some View {
        Section {
            HStack {
                Text("Version")
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(Utilities.appVersion ?? "")
                    .foregroundStyle(.secondary)
                /// this reads the width of the text and sends it the to `@State variable` above
                    .background(
                        GeometryReader { geometry in
                            Color.black.opacity(0.001)
                                .preference(key: TextWidthPreferenceKey.self, value: geometry.size.width)
                        }
                    )
                    .onPreferenceChange(TextWidthPreferenceKey.self) { width in
                        versionTextWidth = width
                    }
            }

            HStack {
                Text("Build Number")
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(Utilities.buildNumber ?? "")
                    .frame(width: versionTextWidth, alignment: .center)
                    .foregroundStyle(.secondary)
            }

            Text("Contact Us")
                .foregroundStyle(.blue)
        } header: {
            Text("Application")
        }
    }

    private var aboutSection: some View {
        Section {

        } header: {
            Text("Developed by ") +
            Text("Youssef Mohamed")
                .fontWeight(.medium)
                .foregroundStyle(.accent)
        }
        .font(.callout)
    }
}

// MARK: - Seperate Business Logic out of Views
extension SettingsView {
    private func dismissScreen() async {
        dismiss()
        try? await Task.sleep(for: .seconds(0.25))
        appState.updateViewState(showTabBar: false)
    }

    private func onSignOutPressed() {
        Task {
            do {
                try authServices.signOut()
                await dismissScreen()
            } catch {
                showAlert = AnyAppAlert(error: error)
            }
        }
    }

    private func onCreateAccountPressed() {
        showCreateAccountView = true
    }

    private var premiumStatus: String {
        isPremium ? "Premium" : "Free"
    }

    func setAnonymousAccountStatus() {
        isAnonymousUser = authServices.getAuthenticatedUser()?.isAnonymous == true
    }

    private func onDeleteAccountPressed() {
        showAlert = AnyAppAlert(
            title: "Delete Account?",
            subtitle: "Are you sure you want to delete your account?",
            buttons: {
                AnyView(
                    Button("Delete", role: .destructive) {
                        onDeleteAccountConfirmed()
                    }
                )
            }
        )
    }

    private func onDeleteAccountConfirmed() {
        Task {
            do {
                try await authServices.deleteAccount()
                setAnonymousAccountStatus()
                await dismissScreen()
            } catch {
                showAlert = AnyAppAlert(error: error)
            }
        }
    }
}

#Preview("No Auth") {
    SettingsView()
        .environment(\.authServices, MockAuthService(user: nil))
        .environment(AppState())
}

#Preview("Anonymous") {
    SettingsView()
        .environment(\.authServices, MockAuthService(user: UserAuthInfo.mock(isAnonymous: true)))
        .environment(AppState())
}

#Preview("Not Anonymous") {
    SettingsView()
        .environment(\.authServices, MockAuthService(user: UserAuthInfo.mock(isAnonymous: false)))
        .environment(AppState())
}
