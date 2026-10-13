//
//  LinkProviderView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 11/03/2026.
//

import SwiftUI
import AuthenticationServices

struct LinkProviderView: View {
    @Environment(\.dismiss) private var dismiss
    @State var viewModel: LinkProviderViewModel

    var onDidSignIn: ((_ isNewUser: Bool) -> Void)?

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                viewHeader
                textFields

                Text(viewModel.usageOption.ctaButtonTitle)
                    .callToActionButton()
                    .styledButton(.pressable) {
                        viewModel.signingActionMethod(onDidSignIn: handleDidSignIn)
                    }
                    .accessibilityIdentifier(AccessibilityID.Account.submit)

                HStack {
                    VStack {
                        Divider()
                    }
                    Text("OR")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    VStack {
                        Divider()
                    }
                }
                .padding(.vertical, 8)

                SignInWithAppleButton(viewModel.usageOption == .signIn ? .signIn : .signUp) { _ in
                    // No logic requested
                } onCompletion: { _ in
                    // No logic requested
                }
                .styledButton(.pressable) {
                    viewModel.onSignInApple(onDidSignIn: handleDidSignIn)
                }
                .signInWithAppleButtonStyle(.black)
                .frame(height: 50)
                .cornerRadius(10)
                .accessibilityIdentifier(AccessibilityID.Account.apple)

                Spacer()

                HStack(spacing: 4) {
                    Text(viewModel.usageOption == .createAccount ? "Already have an account?" : "Don't have an account?")
                        .foregroundStyle(.secondary)

                    Text(viewModel.usageOption == .createAccount ? "Log In" : "Create Account")
                        .underline()
                        .fontWeight(.bold)
                        .styledButton(.plain) {
                            withAnimation(.default) {
                                viewModel.onSwitchModePressed()
                            }
                        }
                        .accessibilityIdentifier(AccessibilityID.Account.switchMode)
                }
                .font(.footnote)

            }
            .screenAppearAnalytics(viewName: "LinkProviderView")
            .showCustomAlert(alert: $viewModel.showAlert)
            .padding(24)
        }
    }

    private var viewHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.usageOption.title)
                .accessibilityIdentifier(AccessibilityID.Account.title)
                .font(.title.bold())
            VStack(alignment: .leading, spacing: 0) {
                Text("Don't Lose Your Data!")
                Text("Connect to an SSO Provider to \(viewModel.usageOption == .signIn ? "Sign In to" : "Save") Your Account")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 40)
    }

    private var textFields: some View {
        Group {
            VStack(spacing: 16) {
                if viewModel.usageOption == .createAccount {
                    CustomTextField(text: $viewModel.fullName, placeholder: "Full Name", icon: "person", accessibilityIdentifier: AccessibilityID.Account.fullName)
                }
                CustomTextField(text: $viewModel.email, placeholder: "Email", icon: "envelope", accessibilityIdentifier: AccessibilityID.Account.email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)

                passwordField
            }
        }
    }

    private var passwordField: some View {
        HStack {
            Image(systemName: "lock")
                .foregroundStyle(.secondary)

            Group {
                if viewModel.isPasswordVisible {
                    TextField("Password", text: $viewModel.password)
                        .accessibilityIdentifier(AccessibilityID.Account.password)
                } else {
                    SecureField("Password", text: $viewModel.password)
                        .accessibilityIdentifier(AccessibilityID.Account.password)
                }
            }

            Button {
                viewModel.isPasswordVisible.toggle()
            } label: {
                Image(systemName: viewModel.isPasswordVisible ? "eye.slash" : "eye")
                    .foregroundStyle(.secondary)
            }
            .accessibilityIdentifier(AccessibilityID.Account.passwordVisibility)
            .accessibilityLabel(viewModel.isPasswordVisible ? "Hide password" : "Show password")
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }

    private func handleDidSignIn(isNewUser: Bool) {
        onDidSignIn?(isNewUser)
        dismiss()
    }
}

#Preview("Create Account") {
    let container = DevPreview.shared.container
    let logManager = LogManager(services: [ConsoleService()])
    container.register(LogManager.self, service: logManager)
    container.register(AuthManager.self, service: AuthManager(service: MockAuthService(user: nil)))
    container.register(UserManager.self, service: UserManager(services: MockUserServicesContainer(user: nil)))

    return LinkProviderView(
        viewModel: LinkProviderViewModel(
            interactor: CoreInteractor(container: container),
            usageOption: .createAccount
        )
    )
    .previewEnvironment()
    .environment(container)
    .environment(logManager)
}

#Preview("Sign In") {
    let container = DevPreview.shared.container
    let logManager = LogManager(services: [ConsoleService()])
    container.register(LogManager.self, service: logManager)
    container.register(AuthManager.self, service: AuthManager(service: MockAuthService(user: .mock())))
    container.register(UserManager.self, service: UserManager(services: MockUserServicesContainer(user: .mock)))

    return LinkProviderView(
        viewModel: LinkProviderViewModel(
            interactor: CoreInteractor(container: container),
            usageOption: .signIn
        )
    )
    .previewEnvironment()
    .environment(container)
    .environment(logManager)
}
