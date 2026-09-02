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

    var asEventParameter: [String: Any] {
        return ["title": title]
    }
}

struct LinkProviderView: View {
    @Environment(LogManager.self) private var logManager
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
                                let targetOption: LinkProviderViewOptions = (usageOption == .createAccount) ? .signIn : .createAccount
                                logManager.trackEvent(event: LinkProviderViewEvent.switchModePressed(to: targetOption))
                                usageOption = targetOption
                            }
                        }
                }
                .font(.footnote)

            }
            .screenAppearAnalytics(viewName: "LinkProviderView")
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
        logManager.trackEvent(event: LinkProviderViewEvent.signInAppleStart)

        Task {
            do {
                let authInfo = try await authManager.signInApple()

                try await userManager.logIn(auth: authInfo.user, isNewUser: authInfo.isNewUser)
                let currentUser = userManager.currentUser

                logManager.trackEvent(event: LinkProviderViewEvent.signInAppleSuccess(user: currentUser, isNewUser: authInfo.isNewUser))
                
                onDidSignIn?(authInfo.isNewUser)
                dismiss()
            } catch {
                logManager.trackEvent(event: LinkProviderViewEvent.signInAppleFail(error: error))
                showAlert = AnyAppAlert(error: error)
            }
        }
    }

    func signInEmail() {
        logManager.trackEvent(event: LinkProviderViewEvent.signInEmailStart)

        Task {
            do {
                let authInfo = try await authManager.signInEmail(email: email, password: password)
                try await userManager.logIn(auth: authInfo.user, isNewUser: authInfo.isNewUser)

                let currentUser = userManager.currentUser
                logManager.trackEvent(event: LinkProviderViewEvent.signInEmailSuccess(user: currentUser, isNewUser: authInfo.isNewUser))

                onDidSignIn?(authInfo.isNewUser)
                dismiss()
            } catch {
                logManager.trackEvent(event: LinkProviderViewEvent.signInEmailFail(error: error))
                showAlert = AnyAppAlert(error: error)
            }
        }
    }

    func createAccountEmail() {
        logManager.trackEvent(event: LinkProviderViewEvent.createAccountEmailStart)

        Task {
            do {
                let authInfo = try await authManager.createAccountEmail(email: email, password: password)
                try await userManager.logIn(auth: authInfo.user, isNewUser: authInfo.isNewUser)

                let currentUser = userManager.currentUser
                logManager.trackEvent(event: LinkProviderViewEvent.createAccountEmailSuccess(user: currentUser, isNewUser: authInfo.isNewUser))

                onDidSignIn?(authInfo.isNewUser)
                dismiss()
            } catch {
                logManager.trackEvent(event: LinkProviderViewEvent.createAccountEmailFail(error: error))
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

extension LinkProviderView {
    enum LinkProviderViewEvent: LoggableEvent {
        case switchModePressed(to: LinkProviderViewOptions)
        case signInAppleStart, signInAppleSuccess(user: UserModel?, isNewUser: Bool), signInAppleFail(error: Error)
        case signInEmailStart, signInEmailSuccess(user: UserModel?, isNewUser: Bool), signInEmailFail(error: Error)
        case createAccountEmailStart, createAccountEmailSuccess(user: UserModel?, isNewUser: Bool), createAccountEmailFail(error: Error)

        var eventName: String {
            switch self {
            case .switchModePressed:
                return "LinkProviderView_SwitchMode_Pressed"
            case .signInAppleStart:
                return "LinkProviderView_SignInApple_Start"
            case .signInAppleSuccess:
                return "LinkProviderView_SignInApple_Success"
            case .signInAppleFail:
                return "LinkProviderView_SignInApple_Fail"
            case .signInEmailStart:
                return "LinkProviderView_SignInEmail_Start"
            case .signInEmailSuccess:
                return "LinkProviderView_SignInEmail_Success"
            case .signInEmailFail:
                return "LinkProviderView_SignInEmail_Fail"
            case .createAccountEmailStart:
                return "LinkProviderView_CreateAccountEmail_Start"
            case .createAccountEmailSuccess:
                return "LinkProviderView_CreateAccountEmail_Success"
            case .createAccountEmailFail:
                return "LinkProviderView_CreateAccountEmail_Fail"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .switchModePressed(to: let option):
                return option.asEventParameter

            case .signInAppleSuccess(user: let user, isNewUser: let isNewUser),
                 .signInEmailSuccess(user: let user, isNewUser: let isNewUser),
                 .createAccountEmailSuccess(user: let user, isNewUser: let isNewUser):
                return (user?.asEventParameter ?? [:])
                    .merged(isNewUser.asEventParameter(key: "is_new_user"))

            case .signInAppleFail(error: let error),
                 .signInEmailFail(error: let error),
                 .createAccountEmailFail(error: let error):
                return error.asEventParameter

            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .signInAppleFail, .signInEmailFail, .createAccountEmailFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}

#Preview("Create Account") {
    LinkProviderView(usageOption: .createAccount)
        .environment(LogManager(services: [ConsoleService()]))
        .previewEnvironment(isSignedIn: false)
}

#Preview("Sign In") {
    LinkProviderView(usageOption: .signIn)
        .environment(LogManager(services: [ConsoleService()]))
        .previewEnvironment(isSignedIn: true)
}
