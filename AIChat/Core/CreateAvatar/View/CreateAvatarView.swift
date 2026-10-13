//
//  CreateAvatarView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 12/03/2026.
//

import SwiftUI

struct CreateAvatarView: View {
    @Environment(\.dismiss) private var dismiss
    @State var viewModel: CreateAvatarViewModel

    var body: some View {
        NavigationStack {
            List {
                nameSection

                attributesSection

                imageSection

                saveButton
            }
            .accessibilityIdentifier(AccessibilityID.CreateAvatar.list)
            .onAppear {
                viewModel.resetForm()
            }
            .screenAppearAnalytics(viewName: "CreateAvatarView")
            .navigationTitle("Create Avatar")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    backButton
                }
            }
            .showCustomAlert(alert: $viewModel.alert)
        }
    }

    private var backButton: some View {
        Image(systemName: "xmark")
            .foregroundStyle(.accent)
            .fontWeight(.semibold)
            .styledButton(.plain) {
                viewModel.onBackButtonPressed(onDismiss: {
                    dismiss()
                })
            }
            .accessibilityLabel("Close avatar creation")
            .accessibilityIdentifier(AccessibilityID.CreateAvatar.close)
    }

    private var saveButton: some View {
        AsyncCallToActionButton(title: "Save", buttonColor: .accent, conditionToLoad: $viewModel.isSavingAvatar) {
            if !viewModel.avatarName.isEmpty && viewModel.generatedImage != nil {
                viewModel.onSaveButtonPressed(onDismiss: {
                    dismiss()
                })
            }
        }
        .accessibilityIdentifier(AccessibilityID.CreateAvatar.save)
        .opacity(viewModel.avatarName.isEmpty || viewModel.generatedImage == nil ? 0.6 : 1)
        .removeListRowFormatting()
    }

    private var nameSection: some View {
        Section {
            TextField("Enter Avatar Name", text: $viewModel.avatarName)
                .accessibilityIdentifier(AccessibilityID.CreateAvatar.name)
        } header: {
            Text("Name Your Avatar*")
        }
    }

    private var attributesSection: some View {
        Section {
            Picker(selection: $viewModel.characterOption) {
                ForEach(CharacterOption.allCases, id: \.self) { option in
                    Text(option.rawValue)
                        .accessibilityIdentifier(AccessibilityID.CreateAvatar.characterOption(option.rawValue))
                        .tag(option) /// to know what option is selected
                }
            } label: {
                Text("is \(viewModel.characterOption.prefix.lowercased()) ...")
            }
            .accessibilityIdentifier(AccessibilityID.CreateAvatar.character)
            .accessibilityValue(viewModel.characterOption.rawValue)

            Picker(selection: $viewModel.characterAction) {
                ForEach(CharacterAction.allCases, id: \.self) { action in
                    Text(action.rawValue)
                        .accessibilityIdentifier(AccessibilityID.CreateAvatar.actionOption(action.rawValue))
                        .tag(action)
                }
            } label: {
                Text("that is ...")
            }
            .accessibilityIdentifier(AccessibilityID.CreateAvatar.action)
            .accessibilityValue(viewModel.characterAction.rawValue)

            Picker(selection: $viewModel.characterLocation) {
                ForEach(CharacterLocation.allCases, id: \.self) { location in
                    Text(location.rawValue)
                        .accessibilityIdentifier(AccessibilityID.CreateAvatar.locationOption(location.rawValue))
                        .tag(location) /// to know what option is selected
                }
            } label: {
                Text("in the ...")
            }
            .accessibilityIdentifier(AccessibilityID.CreateAvatar.location)
            .accessibilityValue(viewModel.characterLocation.rawValue)

        } header: {
            Text("Attributes")
        }
    }

    private var imageSection: some View {
        Section {
            HStack(alignment: .top) {
                Group {
                    if viewModel.isGeneratingImage != true {
                        Text("Generate Image")
                            .underline()
                            .foregroundStyle(.accent)
                            .styledButton(.plain) {
                                viewModel.onGenerateImagePressed()
                            }
                            .accessibilityIdentifier(AccessibilityID.CreateAvatar.generate)
                    } else {
                        ProgressView()
                            .accessibilityIdentifier(AccessibilityID.CreateAvatar.generating)
                            .tint(.accent)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)

                Circle()
                    .fill(.gray.opacity(0.4))
                    .frame(width: 220, height: 220)
                    .overlay(
                        ZStack {
                            if let generatedImage = viewModel.generatedImage {
                                Image(uiImage: generatedImage)
                                    .resizable()
                                    .scaledToFill()
                                    .clipShape(Circle())
                                    .accessibilityLabel("Generated avatar image")
                                    .accessibilityIdentifier(AccessibilityID.CreateAvatar.generatedImage)
                            }
                        }
                    )
            }
            .padding(.horizontal, 10)
            .removeListRowFormatting()
        }
    }
}

#Preview {
    NavigationStack {
        CreateAvatarView(
            viewModel: CreateAvatarViewModel(interactor: CoreInteractor(container: DevPreview.shared.container))
        )
    }
    .previewEnvironment()
}
