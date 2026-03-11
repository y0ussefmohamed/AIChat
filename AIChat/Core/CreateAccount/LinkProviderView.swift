//
//  LinkProviderView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 11/03/2026.
//

import SwiftUI
import AuthenticationServices // Official Apple button

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
}

struct LinkProviderView: View {
    var usageOption: LinkProviderViewOptions
    @Environment(\.dismiss) var dismiss
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                viewHeader
                textFields

                Text("Sign Up")
                    .callToActionButton()
                    .styledButton(.pressable) {

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

                SignInWithAppleButton(.signIn) { _ in
                    // No logic requested
                } onCompletion: { _ in
                    // No logic requested
                }
                .styledButton(.pressable) {

                }
                .signInWithAppleButtonStyle(.black)
                .frame(height: 50)
                .cornerRadius(10)

                Spacer()

                if usageOption == .createAccount {
                    HStack(spacing: 4) {
                        Text("Already have an account?")
                            .foregroundStyle(.secondary)

                        Text("Log In")
                            .underline()
                            .fontWeight(.bold)
                            .styledButton(.plain) {
                                dismiss()
                            }
                    }
                    .font(.footnote)
                }
            }
            .padding(24)
        }
    }

    private var viewHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(usageOption.title)
                .font(.title.bold())
            Text("Don't Lose Your Data! \nConnect to an SSO Provider to Save Your Account")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 40)
    }

    private var textFields: some View {
        Group {
            VStack(spacing: 16) {
                CustomTextField(text: $fullName, placeholder: "Full Name", icon: "person")
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

#Preview("Create Account") {
    LinkProviderView(usageOption: .createAccount)
}

#Preview("Sign In") {
    LinkProviderView(usageOption: .signIn)
}
