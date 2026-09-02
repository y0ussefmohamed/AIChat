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
    @Environment(LogManager.self) private var logManager
    @Environment(AppState.self) private var appState
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(ChatManager.self) private var chatManager
    @Environment(\.dismiss) private var dismiss
    @State private var isPremium: Bool = true
    @State private var versionTextWidth: CGFloat = 0
    @State private var showCreateAccountView: Bool = false
    @State private var showAlert: AnyAppAlert?

    private var isAnonymousUser: Bool {
        authManager.auth?.isAnonymous ?? false
    }

    var body: some View {
        NavigationStack {
            List {
                accountSection

                purchasesSection

                applicationSection

                aboutSection
                    .offset(y: -5)
            }
            .screenAppearAnalytics(viewName: "SettingsView")
            .showCustomAlert(alert: $showAlert)
            .sheet(isPresented: $showCreateAccountView) {
                LinkProviderView(usageOption: .createAccount)
            }
            .navigationTitle("Settings")
        }
    }

    private var accountSection: some View {
        Section {
            if isAnonymousUser {
                Text("Save & Backup Account")
                    .styledButton(.plain, action: onCreateAccountPressed)
            } else {
                if authManager.auth == nil {
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
                            onManagePurchasesPressed()
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
                .styledButton(.plain) {
                    onContactUsPressed()
                }
        } header: {
            Text("Application")
        }
    }

    private var aboutSection: some View {
        Section {

        } header: {
            VStack(alignment: .leading) {
                Text("Developed by ") +
                Text("Youssef Mohamed")
                    .fontWeight(.medium)
                    .foregroundStyle(.accent)

                Text("For ") +
                Text(userManager.currentUser?.email ?? "Unknown 👀")
                    .fontWeight(.medium)
                    .foregroundStyle(.accent)
            }
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
        logManager.trackEvent(event: SettingsViewEvent.signOutStart)
        Task {
            do {
                try authManager.signOut()
                userManager.signOut()
                logManager.trackEvent(event: SettingsViewEvent.signOutSuccess)
                await dismissScreen()
            } catch {
                logManager.trackEvent(event: SettingsViewEvent.signOutFail(error: error))
                showAlert = AnyAppAlert(error: error)
            }
        }
    }

    private func onCreateAccountPressed() {
        logManager.trackEvent(event: SettingsViewEvent.createAccountPressed)
        showCreateAccountView = true
    }

    private var premiumStatus: String {
        isPremium ? "Premium" : "Free"
    }

    private func onManagePurchasesPressed() {
        logManager.trackEvent(event: SettingsViewEvent.managePurchasesPressed)
    }

    private func onContactUsPressed() {
        logManager.trackEvent(event: SettingsViewEvent.contactUsPressed)
    }

    private func onDeleteAccountPressed() {
        logManager.trackEvent(event: SettingsViewEvent.deleteAccountPressed)
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
        logManager.trackEvent(event: SettingsViewEvent.deleteAccountStart)
        Task {
            do {
                let uid = try authManager.getAuthId()

                async let removeAvatars = avatarManager.removeAuthorIdFromTheDeletedUserAvatars(userId: uid)
                async let deleteUser = userManager.deleteCurrentUser()
                async let deleteAuth = authManager.deleteAccount()
                async let deleteChats = chatManager.deleteAllChats(userId: uid)

                _ = try await (removeAvatars, deleteUser, deleteAuth, deleteChats)
                logManager.deleteUserProfile()

                logManager.trackEvent(event: SettingsViewEvent.deleteAccountSuccess)
                await dismissScreen()
            } catch {
                logManager.trackEvent(event: SettingsViewEvent.deleteAccountFail(error: error))
                showAlert = AnyAppAlert(error: error)
            }
        }
    }
}

extension SettingsView {
    enum SettingsViewEvent: LoggableEvent {
        case signOutStart, signOutSuccess, signOutFail(error: Error)
        case createAccountPressed
        case deleteAccountPressed
        case deleteAccountStart, deleteAccountSuccess, deleteAccountFail(error: Error)
        case managePurchasesPressed
        case contactUsPressed

        var eventName: String {
            switch self {
            case .signOutStart:
                return "SettingsView_SignOut_Start"
            case .signOutSuccess:
                return "SettingsView_SignOut_Success"
            case .signOutFail:
                return "SettingsView_SignOut_Fail"
            case .createAccountPressed:
                return "SettingsView_CreateAccount_Pressed"
            case .deleteAccountPressed:
                return "SettingsView_DeleteAccount_Pressed"
            case .deleteAccountStart:
                return "SettingsView_DeleteAccount_Start"
            case .deleteAccountSuccess:
                return "SettingsView_DeleteAccount_Success"
            case .deleteAccountFail:
                return "SettingsView_DeleteAccount_Fail"
            case .managePurchasesPressed:
                return "SettingsView_ManagePurchases_Pressed"
            case .contactUsPressed:
                return "SettingsView_ContactUs_Pressed"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .signOutFail(error: let error),
                 .deleteAccountFail(error: let error):
                return error.asEventParameter
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .deleteAccountFail, .signOutFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}

#Preview("No Auth") {
    SettingsView()
        .environment(LogManager(services: [ConsoleService()]))
        .environment(UserManager(services: MockUserServicesContainer(user: nil)))
        .environment(AuthManager(service: MockAuthService(user: nil)))
        .previewEnvironment()
}

#Preview("Anonymous") {
    SettingsView()
        .environment(LogManager(services: [ConsoleService()]))
        .environment(UserManager(services: MockUserServicesContainer(user: .mock)))
        .environment(AuthManager(service: MockAuthService(user: UserAuthInfo.mock(isAnonymous: true))))
        .previewEnvironment()
}

#Preview("Not Anonymous") {
    SettingsView()
        .environment(LogManager(services: [ConsoleService()]))
        .environment(UserManager(services: MockUserServicesContainer(user: .mock)))
        .environment(AuthManager(service: MockAuthService(user: UserAuthInfo.mock(isAnonymous: false))))
        .previewEnvironment()
}
