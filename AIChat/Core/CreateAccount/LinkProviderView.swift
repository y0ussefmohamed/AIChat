//
//  LinkProviderView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 11/03/2026.
//

import SwiftUI
import AuthenticationServices

enum LinkProviderViewOptions: String {
    case signIn
    case createAccount

    var title: String {
        switch self {
        case .signIn:
            return "Sign In"
        case .createAccount:
            return "Create Account"
        }
    }

    var ctaButtonTitle: String {
        switch self {
        case .signIn:
            "Sign In"
        case .createAccount:
            "Sign Up"
        }
    }
}

struct LinkProviderView: View {
    @Environment(AuthManager.self) var authManager
    @Environment(UserManager.self) var userManager
    @Environment(\.dismiss) var dismiss

    @State var usageOption: LinkProviderViewOptions
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    var onDidSignIn: ((_ isNewUser: Bool) -> Void)?
    @State private var showAlert: AnyAppAlert?

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                viewHeader
                textFields

                Text(usageOption.ctaButtonTitle)
                    .callToActionButton()
                    .styledButton(.pressable) {
                        signingActionMethod()
                    }

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

                SignInWithAppleButton(usageOption == .signIn ? .signIn : .signUp) { _ in
                    // No logic requested
                } onCompletion: { _ in
                    // No logic requested
                }
                .styledButton(.pressable) {
                    onSignInApple()
                }
                .signInWithAppleButtonStyle(.black)
                .frame(height: 50)
                .cornerRadius(10)

                Spacer()

                HStack(spacing: 4) {
                    Text(usageOption == .createAccount ? "Already have an account?" : "Don't have an account?")
                        .foregroundStyle(.secondary)

                    Text(usageOption == .createAccount ? "Log In" : "Create Account")
                        .underline()
                        .fontWeight(.bold)
                        .styledButton(.plain) {
                            withAnimation(.default) {
                                if usageOption == .createAccount {
                                    usageOption = .signIn
                                } else {
                                    usageOption = .createAccount
                                }
                            }
                        }
                }
                .font(.footnote)

            }
            .showCustomAlert(alert: $showAlert)
            .padding(24)
        }
    }

    private var viewHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(usageOption.title)
                .font(.title.bold())
            VStack(alignment: .leading, spacing: 0) {
                Text("Don't Lose Your Data!")
                Text("Connect to an SSO Provider to \(usageOption == .signIn ? "Sign In to" : "Save") Your Account")
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
                if usageOption == .createAccount {
                    CustomTextField(text: $fullName, placeholder: "Full Name", icon: "person")
                }
                CustomTextField(text: $email, placeholder: "Email", icon: "envelope")
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
                if isPasswordVisible {
                    TextField("Password", text: $password)
                } else {
                    SecureField("Password", text: $password)
                }
            }

            Button {
                isPasswordVisible.toggle()
            } label: {
                Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

extension LinkProviderView {
    func onSignInApple() {
        Task {
            do {
                let authInfo = try await authManager.signInApple()
                print("Signed in with Apple: \(String(describing: authInfo.user.email))")

                try await userManager.logIn(auth: authInfo.user, isNewUser: authInfo.isNewUser)
                onDidSignIn?(authInfo.isNewUser)
                dismiss()
            } catch {
                print(error)
            }
        }
    }

    func signInEmail() {
        Task {
            do {
                let authInfo = try await authManager.signInEmail(email: email, password: password)
                print("Signed in with Email: \(String(describing: authInfo.user.email))")

                try await userManager.logIn(auth: authInfo.user, isNewUser: authInfo.isNewUser)
                onDidSignIn?(authInfo.isNewUser)
                dismiss()
            } catch {
                showAlert = AnyAppAlert(error: error)
            }
        }
    }

    func createAccountEmail() {
        Task {
            do {
                let authInfo = try await authManager.createAccountEmail(email: email, password: password)
                print("Created account with Email: \(String(describing: authInfo.user.email))")

                try await userManager.logIn(auth: authInfo.user, isNewUser: authInfo.isNewUser)
                onDidSignIn?(authInfo.isNewUser)
                dismiss()
            } catch {
                showAlert = AnyAppAlert(error: error)
            }
        }
    }

    func signingActionMethod() {
        switch usageOption {
        case .signIn:
            signInEmail()
        case .createAccount:
            createAccountEmail()
        }
    }
}

#Preview("Create Account") {
    LinkProviderView(usageOption: .createAccount)
        .previewEnvironment(isSignedIn: false)
}

#Preview("Sign In") {
    LinkProviderView(usageOption: .signIn)        .previewEnvironment(isSignedIn: true)
}
