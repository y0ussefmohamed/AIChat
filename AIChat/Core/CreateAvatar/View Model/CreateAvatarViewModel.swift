//
//  CreateAvatarViewModel.swift
//  AIChat
//
//  Created by Youssef Mohamed on 12/03/2026.
//

import SwiftUI

@MainActor
@Observable
class CreateAvatarViewModel {
    private let interactor: CreateAvatarInteractor

    private(set) var isGeneratingImage: Bool?
    private(set) var generatedImage: UIImage?

    var isSavingAvatar: Bool = false
    var avatarName: String = ""
    var characterOption: CharacterOption = .default
    var characterAction: CharacterAction = .default
    var characterLocation: CharacterLocation = .default
    var alert: AnyAppAlert?

    init(interactor: CreateAvatarInteractor) {
        self.interactor = interactor
    }

    func onBackButtonPressed(onDismiss: () -> Void) {
        interactor.trackEvent(event: CreateAvatarViewEvent.backButtonPressed)
        onDismiss()
    }

    func onGenerateImagePressed() {
        Task { @MainActor in
            defer { isGeneratingImage = false }
            isGeneratingImage = true

            let prompt = "\(avatarName) is a \(characterOption.rawValue) that is \(characterAction.rawValue) in the \(characterLocation.rawValue)"

            interactor.trackEvent(event: CreateAvatarViewEvent.generateImageStart(prompt: prompt))

            do {
                generatedImage = try await interactor.generateImage(input: prompt)
                interactor.trackEvent(event: CreateAvatarViewEvent.generateImageSuccess)
            } catch {
                interactor.trackEvent(event: CreateAvatarViewEvent.generateImageFail(error: error))
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
                let uid = try interactor.getAuthId()
                let avatar = Avatar.newAvatar(
                    name: avatarName,
                    option: characterOption,
                    action: characterAction,
                    location: characterLocation,
                    authorId: uid
                )

                interactor.trackEvent(event: CreateAvatarViewEvent.saveAvatarStart(avatar: avatar))

                try await interactor.createAvatar(avatar: avatar, image: generatedImage)
                interactor.trackEvent(event: CreateAvatarViewEvent.saveAvatarSuccess(avatar: avatar))

                onDismiss()
            } catch {
                interactor.trackEvent(event: CreateAvatarViewEvent.saveAvatarFail(error: error))
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
