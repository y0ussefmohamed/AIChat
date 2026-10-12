//
//  ProfileViewModel.swift
//  AIChat
//
//  Created by Youssef Mohamed on 13/10/2026.
//

import Foundation
import SwiftUI

@MainActor
@Observable
class ProfileViewModel {
    /// the view model depends on this interactor, which only has the functions needed by this view model instead of several manager classes
    private let interactor: ProfileInteractor

    private(set) var currentUser: UserModel?
    private(set) var currentUserAvatars: [Avatar] = []

    var isLoading: Bool = false
    var showSettingsView: Bool = false
    var showCreateAvatarView: Bool = false
    var alert: AnyAppAlert?
    var navPathStack: [String] = []

    init(interactor: ProfileInteractor) {
        self.interactor = interactor
    }

    func loadData() async {
        self.currentUser = interactor.currentUser

        isLoading = true
        if let userId = currentUser?.userId {
            interactor.trackEvent(event: ProfileViewEvent.loadAvatarsStart)
            do {
                currentUserAvatars = try await interactor.getCurrentUserAvatars(userId: userId)
                interactor.trackEvent(event: ProfileViewEvent.loadAvatarsSuccess(count: currentUserAvatars.count))
            } catch {
                interactor.trackEvent(event: ProfileViewEvent.loadAvatarsFail(error: error))
                alert = AnyAppAlert(error: error)
            }
        }
        isLoading = false
    }

    func onSettingsButtonPressed() {
        interactor.trackEvent(event: ProfileViewEvent.settingsButtonPressed)
        showSettingsView = true
    }

    func onNewAvatarButtonPressed() {
        interactor.trackEvent(event: ProfileViewEvent.newAvatarButtonPressed)
        showCreateAvatarView = true
    }

    func onAvatarPressed(avatar: Avatar) {
        interactor.trackEvent(event: ProfileViewEvent.avatarPressed(avatar: avatar))
        navPathStack.append(avatar.avatarId)
    }

    func onDeleteAvatar(indexSet: IndexSet) {
        guard let index = indexSet.first else { return }
        let avatarToDelete = currentUserAvatars[index]
        currentUserAvatars.remove(atOffsets: IndexSet(integer: index))

        interactor.trackEvent(event: ProfileViewEvent.deleteAvatarStart(avatar: avatarToDelete))

        Task {
            do {
                try await interactor.deleteAvatar(id: avatarToDelete.avatarId)
                interactor.trackEvent(event: ProfileViewEvent.deleteAvatarSuccess(avatar: avatarToDelete))
            } catch {
                interactor.trackEvent(event: ProfileViewEvent.deleteAvatarFail(error: error))
                alert = AnyAppAlert(error: error)
            }
        }
    }
}

extension ProfileViewModel {
    enum ProfileViewEvent: LoggableEvent {
        case loadAvatarsStart, loadAvatarsSuccess(count: Int), loadAvatarsFail(error: Error)
        case settingsButtonPressed
        case newAvatarButtonPressed
        case avatarPressed(avatar: Avatar)
        case deleteAvatarStart(avatar: Avatar), deleteAvatarSuccess(avatar: Avatar), deleteAvatarFail(error: Error)

        var eventName: String {
            switch self {
            case .loadAvatarsStart:
                return "ProfileView_LoadAvatars_Start"
            case .loadAvatarsSuccess:
                return "ProfileView_LoadAvatars_Success"
            case .loadAvatarsFail:
                return "ProfileView_LoadAvatars_Fail"
            case .settingsButtonPressed:
                return "ProfileView_Settings_Pressed"
            case .newAvatarButtonPressed:
                return "ProfileView_NewAvatar_Pressed"
            case .avatarPressed:
                return "ProfileView_Avatar_Pressed"
            case .deleteAvatarStart:
                return "ProfileView_DeleteAvatar_Start"
            case .deleteAvatarSuccess:
                return "ProfileView_DeleteAvatar_Success"
            case .deleteAvatarFail:
                return "ProfileView_DeleteAvatar_Fail"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .loadAvatarsSuccess(count: let count):
                return count.asEventParameter(key: "avatar_count")
            case .loadAvatarsFail(error: let error),
                 .deleteAvatarFail(error: let error):
                return error.asEventParameter
            case .avatarPressed(avatar: let avatar),
                 .deleteAvatarStart(avatar: let avatar),
                 .deleteAvatarSuccess(avatar: let avatar):
                return avatar.asEventParameter
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .loadAvatarsFail, .deleteAvatarFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}
