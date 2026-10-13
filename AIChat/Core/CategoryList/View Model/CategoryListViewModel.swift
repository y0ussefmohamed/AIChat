//
//  CategoryListViewModel.swift
//  AIChat
//
//  Created by Youssef Mohamed on 14/03/2026.
//

import SwiftUI

@MainActor
@Observable
class CategoryListViewModel {
    private let interactor: CategoryListInteractor

    private(set) var avatars: [Avatar] = []
    private(set) var isLoading: Bool = true

    var alert: AnyAppAlert?

    init(interactor: CategoryListInteractor) {
        self.interactor = interactor
    }

    func loadCategoryAvatars(category: CharacterOption?) async {
        defer { isLoading = false }

        interactor.trackEvent(event: CategoryListEvent.loadAvatarStart)
        do {
            if let category {
                avatars = try await interactor.getAvatarsByCategory(category)
            }
            interactor.trackEvent(event: CategoryListEvent.loadAvatarSuccess)
        } catch {
            interactor.trackEvent(event: CategoryListEvent.loadAvatarFail(error: error))
            alert = AnyAppAlert(error: error)
        }
    }

    func onRowTap(_ avatarId: String, navPathStack: inout [NavigationPathOption]) {
        guard let avatar = avatars.first(where: { $0.avatarId == avatarId }) else {
            return
        }

        interactor.trackEvent(event: CategoryListEvent.avatarPressed(avatar: avatar))
        navPathStack.append(.chat(avatarId))
    }
}

extension CategoryListViewModel {
    enum CategoryListEvent: LoggableEvent {
        case loadAvatarStart, loadAvatarSuccess, loadAvatarFail(error: Error)
        case avatarPressed(avatar: Avatar)

        var eventName: String {
            switch self {
            case .loadAvatarStart:
                return "CategoryListView_LoadAvatar_Start"
            case .loadAvatarSuccess:
                return "CategoryListView_LoadAvatar_Success"
            case .loadAvatarFail:
                return "CategoryListView_LoadAvatar_Fail"
            case .avatarPressed:
                return "CategoryListView_Avatar_Pressed"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .loadAvatarFail(error: let error):
                return error.asEventParameter
            case .avatarPressed(avatar: let avatar):
                return avatar.asEventParameter
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .loadAvatarFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}
