//
//  ExploreView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 04/03/2026.
//

import SwiftUI

struct ExploreView: View {
    @Environment(LogManager.self) private var logManager
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(PushManager.self) private var pushManager

    @State private var featuredAvatars: [Avatar] = []
    @State private var categories: [CharacterOption] = CharacterOption.allCases
    @State private var popularAvatars: [Avatar] = []

    @State private var navPathStack: [NavigationPathOption] = []
    @State private var featuredDidLoad: Bool = false
    @State private var popularDidLoad: Bool = false
    @State private var showDevSettings: Bool = false
    @State private var alert: AnyAppAlert?
    @State private var showNotificationButton: Bool = true
    @State private var showPushNotificationModal: Bool = false

    var body: some View {
        NavigationStack(path: $navPathStack) {
            List {
                if featuredDidLoad {
                    featuredSection
                } else {
                    featuredLoadingView
                }

                if popularDidLoad {
                    categoriesSection
                } else {
                    categoriesLoadingView
                }

                if popularDidLoad {
                    popularSection
                } else {
                    popularLoadingView
                }
            }
            .screenAppearAnalytics(viewName: "ExploreView")
            .navigationTitle("Explore")
            .toolbar(content: {
                ToolbarItem(placement: .topBarLeading) {
                    #if DEBUG
                    devSettingsButton
                    #endif
                }

                ToolbarItem(placement: .topBarTrailing) {
                    if !popularDidLoad || !featuredDidLoad {
                        ProgressView()
                    } else {
                        if showNotificationButton {
                            pushNotificationButton
                        }
                    }
                }
            })
            .showModal(isPresented: $showPushNotificationModal) {
                pushNotificationModal
            }
            .sheet(isPresented: $showDevSettings) {
                DevSettingsView()
            }
            .navigationDestination(for: NavigationPathOption.self) { pathOptionTop in
                switch pathOptionTop {
                case .chat(let avatarId):
                    ChatView(avatarId: avatarId)
                case .category(let category, let imageName):
                    CategoryListView(category: category, categoryImageName: imageName, navPathStack: $navPathStack)
                }
            }
            .task {
                await handleShowNotificationButton()

                let userAllowedNotifications = await pushManager.isAuthorized()
                if userAllowedNotifications {
                    try? await pushManager.schedulePushNotificationsForTheNextWeek()
                }
            }
            .onFirstAppear {
                loadFeaturedAvatars()
                loadPopularAvatars()
            }
            .onOpenURL { url in
                handleDeepLink(url: url)
            }
        }
    }
}

extension ExploreView {
    private var featuredLoadingView: some View {
        Section {
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(0.25))
                    .frame(height: 200)

                VStack(alignment: .leading, spacing: 8) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.35))
                        .frame(width: 140, height: 16)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.35))
                        .frame(width: 220, height: 12)
                }
                .padding(16)
            }
            .padding(.horizontal)
            .shimmering()
            .removeListRowFormatting()
        } header: {
            Text("Featured")
        }
    }

    private var categoriesLoadingView: some View {
        Section {
            ScrollView(.horizontal) {
                HStack(spacing: 12) {
                    ForEach(0..<5, id: \.self) { _ in
                        ZStack(alignment: .bottomLeading) {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.25))
                                .frame(width: 140, height: 150)

                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.35))
                                .frame(width: 80, height: 12)
                                .padding(12)
                        }
                        .shimmering()
                    }
                }
                .frame(height: 150)
            }
            .scrollIndicators(.never)
            .removeListRowFormatting()
        } header: {
            Text("Categories")
        }
    }

    private var popularLoadingView: some View {
        Section {
            ForEach(0..<5, id: \.self) { _ in
                HStack(spacing: 12) {
                    Circle()
                        .fill(Color.gray.opacity(0.25))
                        .frame(width: 60, height: 60)

                    VStack(alignment: .leading, spacing: 8) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.25))
                            .frame(width: 140, height: 14)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.25))
                            .frame(height: 12)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.25))
                            .frame(maxWidth: 200)
                            .frame(height: 12)
                    }

                    Spacer(minLength: 0)
                }
                .padding(.vertical, 8)
                .shimmering()
                .removeListRowFormatting()
            }
        } header: {
            Text("Popular")
        }
    }

    private var featuredSection: some View {
        Section {
            CarouselView(items: featuredAvatars) { avatar in
                HeroCellView(
                    imageName: avatar.profileImageName,
                    title: avatar.name,
                    subtitle: avatar.characterDescription,
                )
                .styledButton {
                    onAvatarPressed(avatar.avatarId)
                }
            }
            .removeListRowFormatting()
        } header: {
            Text("Featured")
        }
    }

    private func retryButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text("Try Again")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.accentColor, in: Capsule())
        }
        .padding(.bottom, 8)
    }

    private var categoriesSection: some View {
        Section {
            ScrollView(.horizontal) {
                HStack(spacing: 12) {
                    ForEach(categories, id: \.self) { category in
                        let imageName = popularAvatars.last(
                            where: {
                                $0.characterOption == category
                            })?.profileImageName

                        if let imageName {
                            CategoryCellView(
                                title: category.pluralRawValue.capitalized,
                                imageName: imageName
                            )
                            .styledButton(.pressable) {
                                onCategoryPressed(category, imageName)
                            }
                        }
                    }
                }
                .frame(height: 150)
            }
            .scrollIndicators(.never)
            /// Page like scrolling
            .scrollTargetLayout()
            .scrollTargetBehavior(.viewAligned)
            .removeListRowFormatting()
        } header: {
            Text("Categories")
        }
    }

    private var popularSection: some View {
        Section {

            ForEach(popularAvatars, id: \.self) { avatar in
                CustomListCellView(
                    avatarName: avatar.name,
                    avatarDescription: avatar.characterDescription,
                    imageName: avatar.profileImageName
                )
                .styledButton(.highlighted) {
                    onAvatarPressed(avatar.avatarId)
                }
                .removeListRowFormatting()
            }

        } header: {
            Text("Popular")
        }
    }

    private func handleDeepLink(url: URL) {
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
        showNotificationButton = await pushManager.canRequestAuthorization()
    }

    private var pushNotificationButton: some View {
        Image(systemName: "bell.fill")
            .font(.headline)
            .styledButton {
                showPushNotificationModal = true
            }
    }

    private var pushNotificationModal: some View {
        CustomModalView(
            title: "Enable Notifications",
            subtitle: "Turn on push notifications to stay updated with important alerts and reminders.",
            primaryButtonTitle: "Enable",
            primaryButtonAction: {
                showPushNotificationModal = false

                Task {
                    do {
                        /// this opens the IOS Real `Built-in` Push Notification Enable Modal
                        let userDidAllowNotifications = try await pushManager.requestAuthorization()

                        if userDidAllowNotifications {
                            try await pushManager.schedulePushNotificationsForTheNextWeek()
                        }

                        /// if notifications is allowed/disallowed then reset `showNotificationButton`
                        await handleShowNotificationButton()
                    } catch {
                        alert = AnyAppAlert(error: error)
                    }
                }
            },
            secondaryButtonTitle: "Not Now",
            secondaryButtonAction: {
                showPushNotificationModal = false
            }
        )
    }

    private func loadFeaturedAvatars() {
        featuredDidLoad = false
        logManager.trackEvent(event: ExploreViewEvent.loadFeaturedStart)

        Task {
            do {
                featuredAvatars = try await avatarManager.getFeaturedAvatars()
                featuredDidLoad = true
                logManager.trackEvent(event: ExploreViewEvent.loadFeaturedSuccess(count: featuredAvatars.count))
            } catch {
                logManager.trackEvent(event: ExploreViewEvent.loadFeaturedFail(error: error))
                alert = AnyAppAlert(error: error)
            }
        }
    }

    private func loadPopularAvatars() {
        popularDidLoad = false
        logManager.trackEvent(event: ExploreViewEvent.loadPopularStart)

        Task {
            do {
                popularAvatars = try await avatarManager.getPopularAvatars()
                popularDidLoad = true
                logManager.trackEvent(event: ExploreViewEvent.loadPopularSuccess(count: popularAvatars.count))
            } catch {
                logManager.trackEvent(event: ExploreViewEvent.loadPopularFail(error: error))
                alert = AnyAppAlert(error: error)
            }
        }
    }

    private func onAvatarPressed(_ avatarId: String) {
        logManager.trackEvent(event: ExploreViewEvent.avatarPressed(avatarId: avatarId))
        navPathStack.append(.chat(avatarId))
    }

    private func onCategoryPressed(_ category: CharacterOption, _ imageName: String) {
        logManager.trackEvent(event: ExploreViewEvent.categoryPressed(category: category))
        navPathStack.append(.category(category, imageName))
    }

    private var devSettingsButton: some View {
        Text("DEV")
            .foregroundStyle(.blue)
            .styledButton(.plain) {
                onDevSettingsPressed()
            }
    }

    private func onDevSettingsPressed() {
        logManager.trackEvent(event: ExploreViewEvent.devSettingsPressed)
        showDevSettings.toggle()
    }
}

extension ExploreView {
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

#Preview("Has Data") {
    ExploreView()
        .previewEnvironment()
        .environment(LogManager(services: [ConsoleService()]))
        .environment(AvatarManager(services: MockAvatarServices()))
}

#Preview("No Data") {
    ExploreView()
        .previewEnvironment()
        .environment(LogManager(services: [ConsoleService()]))
        .environment(AvatarManager(services: MockAvatarServices(remote: MockAvatarService(avatars: [], delay: 3))))
}

#Preview("Slow Loading") {
    ExploreView()
        .previewEnvironment()
        .environment(LogManager(services: [ConsoleService()]))
        .environment(AvatarManager(services: MockAvatarServices(remote: MockAvatarService(delay: 4))))
}
