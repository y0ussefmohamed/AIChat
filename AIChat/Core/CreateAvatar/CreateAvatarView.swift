//
//  CreateAvatarView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 12/03/2026.
//

import SwiftUI

struct CreateAvatarView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(AIManager.self) private var aiManager
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(\.dismiss) private var dismiss

    @State private var avatarName: String = ""
    @State private var characterOption: CharacterOption = .default
    @State private var characterAction: CharacterAction = .default
    @State private var characterLocation: CharacterLocation = .default

    @State private var isGeneratingImage: Bool?
    @State private var generatedImage: UIImage?
    @State private var isSavingAvatar: Bool = false
    @State private var alert: AnyAppAlert?

    var body: some View {
        NavigationStack {
            List {
                nameSection

                attributesSection

                imageSection

                AsyncCallToActionButton(title: "Save", buttonColor: .accent, conditionToLoad: $isSavingAvatar) {
                    if !avatarName.isEmpty && generatedImage != nil {
                        onSaveButtonPressed()
                    }
                }
                .opacity(avatarName.isEmpty || generatedImage == nil ? 0.6 : 1)
                .removeListRowFormatting()
            }
            .onAppear {
                resetForm()
            }
            .navigationTitle("Create Avatar")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    backButton
                }
            }
            .showCustomAlert(alert: $alert)
        }
    }

    private var backButton: some View {
        Image(systemName: "xmark")
            .foregroundStyle(.accent)
            .fontWeight(.semibold)
            .styledButton(.plain) {
                onBackButtonPressed()
            }
    }

    private var nameSection: some View {
        Section {
            TextField("Enter Avatar Name", text: $avatarName)
        } header: {
            Text("Name Your Avatar*")
        }
    }

    private var attributesSection: some View {
        Section {
            Picker(selection: $characterOption) {
                ForEach(CharacterOption.allCases, id: \.self) { option in
                    Text(option.rawValue)
                        .tag(option) /// to know what option is selected
                }
            } label: {
                Text("is \(characterOption.prefix.lowercased()) ...")
            }

            Picker(selection: $characterAction) {
                ForEach(CharacterAction.allCases, id: \.self) { action in
                    Text(action.rawValue)
                        .tag(action)
                }
            } label: {
                Text("that is ...")
            }

            Picker(selection: $characterLocation) {
                ForEach(CharacterLocation.allCases, id: \.self) { location in
                    Text(location.rawValue)
                        .tag(location) /// to know what option is selected
                }
            } label: {
                Text("in the ...")
            }

        } header: {
            Text("Attributes")
        }
    }

    private var imageSection: some View {
        Section {
            HStack(alignment: .top) {
                Group {
                    if isGeneratingImage != true {
                        Text("Generate Image")
                            .underline()
                            .foregroundStyle(.accent)
                            .styledButton(.plain) {
                                onGenerateImagePressed()
                            }
                    } else {
                        ProgressView()
                            .tint(.accent)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)

                Circle()
                    .fill(.gray.opacity(0.4))
                    .frame(width: 220, height: 220)
                    .overlay(
                        ZStack {
                            if let generatedImage {
                                Image(uiImage: generatedImage)
                                    .resizable()
                                    .scaledToFill()
                                    .clipShape(Circle())
                            }
                        }
                    )
            }
            .padding(.horizontal, 10)
            .removeListRowFormatting()
        }
    }
}

// Business Logic
extension CreateAvatarView {
    private func onBackButtonPressed() {
        dismiss()
    }

    private func onGenerateImagePressed() {
        Task { @MainActor in
            isGeneratingImage = true
            do {
                let prompt = "\(avatarName) is a \(characterOption.rawValue) that is \(characterAction.rawValue) in the \(characterLocation.rawValue)"

                generatedImage = try await aiManager.generateImage(input: prompt)
            } catch {
                print("Failed to generate image: \(error)")
            }
            isGeneratingImage = false
        }
    }

    private func onSaveButtonPressed() {
        guard let generatedImage else { return }
        isSavingAvatar = true

        Task {
            defer { isSavingAvatar = false }

            if avatarName.count < 2 {
                alert = AnyAppAlert(title: "Name your avatar", subtitle: "Please enter a name for your avatar.")
                return
            }

            let uid = try authManager.getAuthId()
            let avatar = Avatar(
                avatarId: UUID().uuidString,
                name: avatarName,
                characterOption: characterOption,
                characterAction: characterAction,
                characterLocation: characterLocation,
                profileImageName: generatedImage.debugDescription,
                authorId: uid,
                dateCreated: .now
            )

            do {
                try await avatarManager.createAvatar(avatar: avatar, image: generatedImage)
                dismiss()
            } catch {
                alert = AnyAppAlert(error: error)
            }
        }
    }

    private func resetForm() {
        generatedImage = nil
        avatarName = ""
        characterAction = .default
        characterOption = .default
        characterLocation = .default
    }
}

#Preview {
    NavigationStack {
        CreateAvatarView()
            .environment(AuthManager(service: MockAuthService(user: .mock())))
            .environment(AIManager(service: MockAIService()))
            .environment(AvatarManager(services: MockAvatarServices()))
    }
}
