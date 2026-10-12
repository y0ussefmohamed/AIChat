//
//  ExploreViewModel.swift
//  AIChat
//
//  Created by Youssef Mohamed on 13/10/2026.
//

import Foundation

@MainActor
@Observable
class ExploreViewModel {
    private let interactor: ExploreInteractor

    let categories: [CharacterOption] = CharacterOption.allCases
    
    /// changes inside the ViewModel
    private(set) var featuredAvatars: [Avatar] = []
    private(set) var popularAvatars: [Avatar] = []
    private(set) var featuredDidLoad: Bool = false
    private(set) var popularDidLoad: Bool = false
    private(set) var showNotificationButton: Bool = true

    /// changes outside the ViewModel (in the View)
    var navPathStack: [NavigationPathOption] = []
    var showDevSettings: Bool = false
    var alert: AnyAppAlert?
    var showPushNotificationModal: Bool = false
    var showCreateAccountView: Bool = false

    var categoryRowTest: CategoryRowTestOption {
        interactor.activeTests.categoryRowTest
    }

    init(interactor: ExploreInteractor) {
        self.interactor = interactor
    }

    func loadData() {
        loadFeaturedAvatars()
        loadPopularAvatars()
        showCreateAccountIfNeeded()
    }

    func handleNotifications() async {
        await handleShowNotificationButton()

        let userAllowedNotifications = await interactor.isAuthorized()
        if userAllowedNotifications {
            try? await interactor.schedulePushNotificationsForTheNextWeek()
        }
    }

    func onNotificationButtonPressed() {
        showPushNotificationModal = true
    }

    func onEnableNotificationsPressed() {
        showPushNotificationModal = false

        Task {
            do {
                let userDidAllowNotifications = try await interactor.requestAuthorization()
                if userDidAllowNotifications {
                    try await interactor.schedulePushNotificationsForTheNextWeek()
                }
                await handleShowNotificationButton()
            } catch {
                alert = AnyAppAlert(error: error)
            }
        }
    }

    func onDismissNotificationsPressed() {
        showPushNotificationModal = false
    }

    func handleDeepLink(url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            return
        }

        for queryItem in queryItems {
            if queryItem.name == "category",
               let value = queryItem.value,
               let category = CharacterOption(rawValue: value) {

                let imageName = popularAvatars.first {
                    $0.characterOption == category
                }?.profileImageName ?? Constants.randomImage

                navPathStack.append(.category(category, imageName))
                return
            }
        }
    }

    private func handleShowNotificationButton() async {
        /// returns false if user allowed or disallowed the notifications
        showNotificationButton = await interactor.canRequestAuthorization()
    }

    private func loadFeaturedAvatars() {
        featuredDidLoad = false
        interactor.trackEvent(event: ExploreViewEvent.loadFeaturedStart)

        Task {
            do {
                featuredAvatars = try await interactor.getFeaturedAvatars()
                featuredDidLoad = true
                interactor.trackEvent(event: ExploreViewEvent.loadFeaturedSuccess(count: featuredAvatars.count))
            } catch {
                interactor.trackEvent(event: ExploreViewEvent.loadFeaturedFail(error: error))
                alert = AnyAppAlert(error: error)
            }
        }
    }

    private func loadPopularAvatars() {
        popularDidLoad = false
        interactor.trackEvent(event: ExploreViewEvent.loadPopularStart)

        Task {
            do {
                popularAvatars = try await interactor.getPopularAvatars()
                popularDidLoad = true
                interactor.trackEvent(event: ExploreViewEvent.loadPopularSuccess(count: popularAvatars.count))
            } catch {
                interactor.trackEvent(event: ExploreViewEvent.loadPopularFail(error: error))
                alert = AnyAppAlert(error: error)
            }
        }
    }

    func onAvatarPressed(_ avatarId: String) {
        interactor.trackEvent(event: ExploreViewEvent.avatarPressed(avatarId: avatarId))
        navPathStack.append(.chat(avatarId))
    }

    func onCategoryPressed(_ category: CharacterOption, _ imageName: String) {
        interactor.trackEvent(event: ExploreViewEvent.categoryPressed(category: category))
        navPathStack.append(.category(category, imageName))
    }

    func onDevSettingsPressed() {
        interactor.trackEvent(event: ExploreViewEvent.devSettingsPressed)
        showDevSettings.toggle()
    }

    /// Shows the account sheet for anonymous users in the create-account experiment.
    private func showCreateAccountIfNeeded() {
        guard interactor.auth?.isAnonymous == true &&
                interactor.activeTests.createAccountTest == true else { return }

        Task {
            try? await Task.sleep(for: .seconds(1))
            showCreateAccountView = true
        }
    }
}

extension ExploreViewModel {
    enum ExploreViewEvent: LoggableEvent {
        case loadFeaturedStart, loadFeaturedSuccess(count: Int), loadFeaturedFail(error: Error)
        case loadPopularStart, loadPopularSuccess(count: Int), loadPopularFail(error: Error)
        case avatarPressed(avatarId: String)
        case categoryPressed(category: CharacterOption)
        case devSettingsPressed

        var eventName: String {
            switch self {
            case .loadFeaturedStart:
                return "ExploreView_LoadFeatured_Start"
            case .loadFeaturedSuccess:
                return "ExploreView_LoadFeatured_Success"
            case .loadFeaturedFail:
                return "ExploreView_LoadFeatured_Fail"
            case .loadPopularStart:
                return "ExploreView_LoadPopular_Start"
            case .loadPopularSuccess:
                return "ExploreView_LoadPopular_Success"
            case .loadPopularFail:
                return "ExploreView_LoadPopular_Fail"
            case .avatarPressed:
                return "ExploreView_Avatar_Pressed"
            case .categoryPressed:
                return "ExploreView_Category_Pressed"
            case .devSettingsPressed:
                return "ExploreView_DevSettings_Pressed"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .loadFeaturedSuccess(count: let count):
                return count.asEventParameter(key: "featured_count")
            case .loadPopularSuccess(count: let count):
                return count.asEventParameter(key: "popular_count")
            case .loadFeaturedFail(error: let error),
                 .loadPopularFail(error: let error):
                return error.asEventParameter
            case .avatarPressed(avatarId: let avatarId):
                return avatarId.asEventParameter(key: "avatar_id")
            case .categoryPressed(category: let category):
                return category.asEventParameter
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .loadFeaturedFail, .loadPopularFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}
