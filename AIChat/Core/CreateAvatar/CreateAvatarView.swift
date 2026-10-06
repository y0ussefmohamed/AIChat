//
//  CreateAvatarView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 12/03/2026.
//

import SwiftUI

@MainActor
@Observable
class CreateAvatarViewModel {
    private let logManager: LogManager
    private let authManager: AuthManager
    private let aiManager: AIManager
    private let avatarManager: AvatarManager

    private(set) var isGeneratingImage: Bool?
    private(set) var generatedImage: UIImage?

    var isSavingAvatar: Bool = false
    var avatarName: String = ""
    var characterOption: CharacterOption = .default
    var characterAction: CharacterAction = .default
    var characterLocation: CharacterLocation = .default
    var alert: AnyAppAlert?

    init(container: DependencyContainer) {        
        self.logManager = container.resolve(LogManager.self)!
        self.authManager = container.resolve(AuthManager.self)!
        self.aiManager = container.resolve(AIManager.self)!
        self.avatarManager = container.resolve(AvatarManager.self)!
    }

    func onBackButtonPressed(onDismiss: () -> Void) {
        logManager.trackEvent(event: CreateAvatarViewEvent.backButtonPressed)
        onDismiss()
    }

    func onGenerateImagePressed() {
        Task { @MainActor in
            defer { isGeneratingImage = false }
            isGeneratingImage = true

            let prompt = "\(avatarName) is a \(characterOption.rawValue) that is \(characterAction.rawValue) in the \(characterLocation.rawValue)"

            logManager.trackEvent(event: CreateAvatarViewEvent.generateImageStart(prompt: prompt))

            do {
                generatedImage = try await aiManager.generateImage(input: prompt)
                logManager.trackEvent(event: CreateAvatarViewEvent.generateImageSuccess)
            } catch {
                logManager.trackEvent(event: CreateAvatarViewEvent.generateImageFail(error: error))
            }
        }
    }

    func onSaveButtonPressed(onDismiss: @escaping () -> Void) {
        guard let generatedImage else { return }
        isSavingAvatar = true

        Task {
            defer { isSavingAvatar = false }

            if avatarName.count < 2 {
                alert = AnyAppAlert(title: "Name your avatar", subtitle: "Please enter a name for your avatar.")
                return
            }

            do {
                let uid = try authManager.getAuthId()
                let avatar = Avatar.newAvatar(
                    name: avatarName,
                    option: characterOption,
                    action: characterAction,
                    location: characterLocation,
                    authorId: uid
                )

                logManager.trackEvent(event: CreateAvatarViewEvent.saveAvatarStart(avatar: avatar))

                try await avatarManager.createAvatar(avatar: avatar, image: generatedImage)
                logManager.trackEvent(event: CreateAvatarViewEvent.saveAvatarSuccess(avatar: avatar))

                onDismiss()
            } catch {
                logManager.trackEvent(event: CreateAvatarViewEvent.saveAvatarFail(error: error))
                alert = AnyAppAlert(error: error)
            }
        }
    }

    func resetForm() {
        generatedImage = nil
        avatarName = ""
        characterAction = .default
        characterOption = .default
        characterLocation = .default
    }
}

extension CreateAvatarViewModel {
    enum CreateAvatarViewEvent: LoggableEvent {
        case backButtonPressed
        case generateImageStart(prompt: String), generateImageSuccess, generateImageFail(error: Error)
        case saveAvatarStart(avatar: Avatar), saveAvatarSuccess(avatar: Avatar), saveAvatarFail(error: Error)

        var eventName: String {
            switch self {
            case .backButtonPressed:
                return "CreateAvatarView_Back_Pressed"
            case .generateImageStart:
                return "CreateAvatarView_GenerateImage_Start"
            case .generateImageSuccess:
                return "CreateAvatarView_GenerateImage_Success"
            case .generateImageFail:
                return "CreateAvatarView_GenerateImage_Fail"
            case .saveAvatarStart:
                return "CreateAvatarView_SaveAvatar_Start"
            case .saveAvatarSuccess:
                return "CreateAvatarView_SaveAvatar_Success"
            case .saveAvatarFail:
                return "CreateAvatarView_SaveAvatar_Fail"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .generateImageStart(prompt: let prompt):
                return prompt.asEventParameter(key: "prompt")
            case .generateImageFail(error: let error),
                 .saveAvatarFail(error: let error):
                return error.asEventParameter
            case .saveAvatarStart(avatar: let avatar),
                 .saveAvatarSuccess(avatar: let avatar):
                return avatar.asEventParameter
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .generateImageFail:
                return .severe
            case .saveAvatarFail:
                return .warning
            default:
                return .analytic
            }
        }
    }
}

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
            viewModel: CreateAvatarViewModel(container: DevPreview.shared.container)
        )
    }
    .previewEnvironment()
}
