//
//  SettingsView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 04/03/2026.
//

import SwiftUI
import SwiftfulUtilities

struct SettingsView: View {
    @Environment(DependencyContainer.self) private var container
    @Environment(\.dismiss) private var dismiss
    @State var viewModel: SettingsViewModel
    @State private var versionTextWidth: CGFloat = 0

    var body: some View {
        NavigationStack {
            List {
                accountSection

                purchasesSection

                applicationSection

                aboutSection
                    .offset(y: -5)
            }
            .accessibilityIdentifier(AccessibilityID.Settings.list)
            .navigationTitle("Settings")
            .screenAppearAnalytics(viewName: "SettingsView")
            .showCustomAlert(alert: $viewModel.showAlert)
            .sheet(isPresented: $viewModel.showCreateAccountView) {
                LinkProviderView(
                    viewModel: LinkProviderViewModel(
                        interactor: CoreInteractor(container: container),
                        usageOption: .createAccount
                    )
                )
            }
            .showModal(isPresented: $viewModel.showRatingModal) {
                ratingsModal
            }
        }
        .alert("Delete Account?", isPresented: $viewModel.showDeleteAccountConfirmation) {
            Button("Delete", role: .destructive) {
                viewModel.onDeleteAccountConfirmed(onDismiss: dismissScreen)
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete your account?")
        }
    }

    private var ratingsModal: some View {
        CustomModalView(
            title: "Are you enjoying AIChat?",
            subtitle: "We'd love to hear your feedback",
            primaryButtonTitle: "YES!",
            primaryButtonAction: {
                viewModel.onRatingButtonPressed()
            },
            secondaryButtonTitle: "Not Yet",
            secondaryButtonAction: {
                viewModel.showRatingModal = false
            },
            accessibilityIdentifier: AccessibilityID.Modal.rating
        )
    }

    private var accountSection: some View {
        Section {
            if viewModel.isAnonymousUser {
                Text("Save & Backup Account")
                    .styledButton(.plain, action: viewModel.onCreateAccountPressed)
                    .accessibilityIdentifier(AccessibilityID.Settings.backup)
            } else {
                if !viewModel.hasUserAccount {
                    Text("No User Account Exists")
                } else {
                    Text("Sign out")
                        .styledButton(.plain) {
                            viewModel.onSignOutPressed(onDismiss: dismissScreen)
                        }
                        .accessibilityIdentifier(AccessibilityID.Settings.signOut)
                }
            }

            Text("Delete Account")
                .foregroundStyle(.red)
                .styledButton(.plain) {
                    viewModel.onDeleteAccountPressed()
                }
                .accessibilityIdentifier(AccessibilityID.Settings.deleteAccount)
        } header: {
            Text("Account")
        }
    }

    private var purchasesSection: some View {
        Section {
            HStack {
                Text("Account Status: \(viewModel.premiumStatus)")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .styledButton(.plain) {

                    }
                    .accessibilityIdentifier(AccessibilityID.Settings.premium)

                if viewModel.isPremium {
                    Text("Manage")
                        .badgeButtonModifier()
                        .styledButton(.pressable) {
                            viewModel.onManagePurchasesPressed()
                        }
                        .accessibilityIdentifier(AccessibilityID.Settings.manage)
                }
            }

        } header: {
            Text("Purchases")
        }
    }

    private var applicationSection: some View {
        Section {
            Text("Enjoy AIChat?")
                .foregroundStyle(LinearGradient(colors: [.orange, .yellow], startPoint: .top, endPoint: .bottom))
                .styledButton(.plain) {
                    viewModel.showRatingModal = true
                }
                .accessibilityIdentifier(AccessibilityID.Settings.rating)

            HStack {
                Text("Version")
                    .accessibilityIdentifier(AccessibilityID.Settings.version)
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
                    .accessibilityIdentifier(AccessibilityID.Settings.build)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(Utilities.buildNumber ?? "")
                    .frame(width: versionTextWidth, alignment: .center)
                    .foregroundStyle(.secondary)
            }

            Text("Contact Us")
                .foregroundStyle(.blue)
                .styledButton(.plain) {
                    viewModel.onContactUsPressed()
                }
                .accessibilityIdentifier(AccessibilityID.Settings.contact)
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
                Text(viewModel.currentUser?.email ?? "Unknown 👀")
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

private extension SettingsView {
    func dismissScreen() async {
        dismiss()
        try? await Task.sleep(for: .seconds(0.25))
        viewModel.updateAppState(showTabBar: false)
    }
}

private func makeSettingsPreviewContainer(auth: UserAuthInfo?, user: UserModel?) -> DependencyContainer {
    let container = DevPreview.shared.container
    container.register(LogManager.self, service: LogManager(services: [ConsoleService()]))
    container.register(AuthManager.self, service: AuthManager(service: MockAuthService(user: auth)))
    container.register(UserManager.self, service: UserManager(services: MockUserServicesContainer(user: user)))
    return container
}

#Preview("No Auth") {
    let container = makeSettingsPreviewContainer(auth: nil, user: nil)

    return SettingsView(viewModel: SettingsViewModel(interactor: CoreInteractor(container: container)))
        .previewEnvironment()
        .environment(container)
}

#Preview("Anonymous") {
    let auth = UserAuthInfo.mock(isAnonymous: true)
    let container = makeSettingsPreviewContainer(auth: auth, user: UserModel(auth: auth, creationVersion: nil))

    return SettingsView(viewModel: SettingsViewModel(interactor: CoreInteractor(container: container)))
        .previewEnvironment()
        .environment(container)
}

#Preview("Not Anonymous") {
    let auth = UserAuthInfo.mock(isAnonymous: false)
    let container = makeSettingsPreviewContainer(auth: auth, user: UserModel(auth: auth, creationVersion: nil))

    return SettingsView(viewModel: SettingsViewModel(interactor: CoreInteractor(container: container)))
        .previewEnvironment()
        .environment(container)
}
