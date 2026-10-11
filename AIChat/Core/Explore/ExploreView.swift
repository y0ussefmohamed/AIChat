//
//  ExploreView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 04/03/2026.
//

import SwiftUI

@MainActor
@Observable
class ExploreViewModel {
    private let logManager: LogManager
    private let authManager: AuthManager
    private let avatarManager: AvatarManager
    private let pushManager: PushManager
    private let abTestManager: ABTestManager
    
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
        abTestManager.activeTests.categoryRowTest
    }

    init(container: DependencyContainer) {
        self.logManager = container.resolve(LogManager.self)!
        self.authManager = container.resolve(AuthManager.self)!
        self.avatarManager = container.resolve(AvatarManager.self)!
        self.pushManager = container.resolve(PushManager.self)!
        self.abTestManager = container.resolve(ABTestManager.self)!
    }

    func loadData() {
        loadFeaturedAvatars()
        loadPopularAvatars()
        showCreateAccountIfNeeded()
    }

    func handleNotifications() async {
        await handleShowNotificationButton()

        let userAllowedNotifications = await pushManager.isAuthorized()
        if userAllowedNotifications {
            try? await pushManager.schedulePushNotificationsForTheNextWeek()
        }
    }

    func onNotificationButtonPressed() {
        showPushNotificationModal = true
    }

    func onEnableNotificationsPressed() {
        showPushNotificationModal = false

        Task {
            do {
                let userDidAllowNotifications = try await pushManager.requestAuthorization()
                if userDidAllowNotifications {
                    try await pushManager.schedulePushNotificationsForTheNextWeek()
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
        showNotificationButton = await pushManager.canRequestAuthorization()
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

    func onAvatarPressed(_ avatarId: String) {
        logManager.trackEvent(event: ExploreViewEvent.avatarPressed(avatarId: avatarId))
        navPathStack.append(.chat(avatarId))
    }

    func onCategoryPressed(_ category: CharacterOption, _ imageName: String) {
        logManager.trackEvent(event: ExploreViewEvent.categoryPressed(category: category))
        navPathStack.append(.category(category, imageName))
    }

    func onDevSettingsPressed() {
        logManager.trackEvent(event: ExploreViewEvent.devSettingsPressed)
        showDevSettings.toggle()
    }

    /// Shows the account sheet for anonymous users in the create-account experiment.
    private func showCreateAccountIfNeeded() {
        guard authManager.auth?.isAnonymous == true &&
              abTestManager.activeTests.createAccountTest == true else { return }

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

struct ExploreView: View {
    @State var viewModel: ExploreViewModel

    var body: some View {
        NavigationStack(path: $viewModel.navPathStack) {
            List {

                if viewModel.categoryRowTest == .top {
                    categoryRow
                }

                if viewModel.featuredDidLoad {
                    featuredSection
                } else {
                    featuredLoadingView
                }

                if viewModel.categoryRowTest == .original {
                    categoryRow
                }

                if viewModel.popularDidLoad {
                    popularSection
                } else {
                    popularLoadingView
                }
            }
            .accessibilityIdentifier(AccessibilityID.Explore.list)
            .screenAppearAnalytics(viewName: "ExploreView")
            .navigationTitle("Explore")
            .toolbar(content: {
                ToolbarItem(placement: .topBarLeading) {
                    #if DEBUG
                    devSettingsButton
                    #endif
                }

                ToolbarItem(placement: .topBarTrailing) {
                    if !viewModel.popularDidLoad || !viewModel.featuredDidLoad {
                        ProgressView()
                    } else {
                        if viewModel.showNotificationButton {
                            pushNotificationButton
                        }
                    }
                }
            })
            .showModal(isPresented: $viewModel.showPushNotificationModal) {
                pushNotificationModal
            }
            .sheet(isPresented: $viewModel.showDevSettings) {
                DevSettingsView()
            }
            .sheet(isPresented: $viewModel.showCreateAccountView) {
                LinkProviderView(usageOption: .createAccount)
            }
            .navigationDestination(for: NavigationPathOption.self) { pathOptionTop in
                switch pathOptionTop {
                case .chat(let avatarId):
                    ChatView(avatarId: avatarId)
                case .category(let category, let imageName):
                    CategoryListView(category: category, categoryImageName: imageName, navPathStack: $viewModel.navPathStack)
                }
            }
            .task {
                await viewModel.handleNotifications()
            }
            .onFirstAppear {
                viewModel.loadData()
            }
            .onOpenURL { url in
                viewModel.handleDeepLink(url: url)
            }
        }
        .showCustomAlert(alert: $viewModel.alert)
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
            CarouselView(items: viewModel.featuredAvatars) { avatar in
                HeroCellView(
                    imageName: avatar.profileImageName,
                    title: avatar.name,
                    subtitle: avatar.characterDescription,
                )
                .styledButton {
                    viewModel.onAvatarPressed(avatar.avatarId)
                }
                .accessibilityIdentifier(AccessibilityID.Explore.featured(avatar.avatarId))
            }
            .accessibilityIdentifier(AccessibilityID.Explore.carousel)
            .removeListRowFormatting()
        } header: {
            Text("Featured")
                .accessibilityIdentifier(AccessibilityID.Explore.featuredTitle)
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
                    ForEach(viewModel.categories, id: \.self) { category in
                        let imageName = viewModel.popularAvatars.last(
                            where: {
                                $0.characterOption == category
                            })?.profileImageName

                        if let imageName {
                            CategoryCellView(
                                title: category.pluralRawValue.capitalized,
                                imageName: imageName
                            )
                            .styledButton(.pressable) {
                                viewModel.onCategoryPressed(category, imageName)
                            }
                            .accessibilityIdentifier(AccessibilityID.Explore.category(category.rawValue))
                        }
                    }
                }
                .frame(height: 150)
            }
            .scrollIndicators(.never)
            .accessibilityIdentifier(AccessibilityID.Explore.categories)
            /// Page like scrolling
            .scrollTargetLayout()
            .scrollTargetBehavior(.viewAligned)
            .removeListRowFormatting()
        } header: {
            Text("Categories")
                .accessibilityIdentifier(AccessibilityID.Explore.categoriesTitle)
        }
    }

    private var popularSection: some View {
        Section {

            ForEach(viewModel.popularAvatars, id: \.self) { avatar in
                CustomListCellView(
                    avatarName: avatar.name,
                    avatarDescription: avatar.characterDescription,
                    imageName: avatar.profileImageName
                )
                .styledButton(.highlighted) {
                    viewModel.onAvatarPressed(avatar.avatarId)
                }
                .accessibilityIdentifier(AccessibilityID.Explore.popular(avatar.avatarId))
                .removeListRowFormatting()
            }

        } header: {
            Text("Popular")
                .accessibilityIdentifier(AccessibilityID.Explore.popularTitle)
        }
    }

    @ViewBuilder
    private var categoryRow: some View {
        if viewModel.popularDidLoad {
            categoriesSection
        } else {
            categoriesLoadingView
        }
    }

    private var pushNotificationButton: some View {
        Image(systemName: "bell.fill")
            .font(.headline)
            .styledButton(action: viewModel.onNotificationButtonPressed)
            .accessibilityLabel("Notification settings")
            .accessibilityIdentifier(AccessibilityID.Explore.notifications)
    }

    private var pushNotificationModal: some View {
        CustomModalView(
            title: "Enable Notifications",
            subtitle: "Turn on push notifications to stay updated with important alerts and reminders.",
            primaryButtonTitle: "Enable",
            primaryButtonAction: viewModel.onEnableNotificationsPressed,
            secondaryButtonTitle: "Not Now",
            secondaryButtonAction: viewModel.onDismissNotificationsPressed,
            accessibilityIdentifier: AccessibilityID.Modal.notifications
        )
    }

    private var devSettingsButton: some View {
        Text("DEV")
            .foregroundStyle(.blue)
            .styledButton(.plain) {
                viewModel.onDevSettingsPressed()
            }
            .accessibilityIdentifier(AccessibilityID.Explore.developerSettings)
    }

}

#Preview("Has Data") {
    ExploreView(viewModel: ExploreViewModel(container: DevPreview.shared.container))
        .previewContainerEnvironment()
        .previewEnvironment()
}

#Preview("Has Data w/ Create Acc Test") {
    let container = DevPreview.shared.container
    container.register(AuthManager.self, service: AuthManager(
        service: MockAuthService(user: .mock(isAnonymous: true)),
        logManager: DevPreview.shared.logManager
    ))
    container.register(ABTestManager.self, service: ABTestManager(service: MockABTestService(createAccountTest: true)))

    return ExploreView(viewModel: ExploreViewModel(container: container))
}

#Preview("CategoryRowTest: Original") {
    let container = DevPreview.shared.container
    container.register(ABTestManager.self, service: ABTestManager(service: MockABTestService(categoryRowTest: .original)))

    return ExploreView(viewModel: ExploreViewModel(container: container))
        .previewEnvironment()
}

#Preview("CategoryRowTest: Top") {
    let container = DevPreview.shared.container
    container.register(ABTestManager.self, service: ABTestManager(service: MockABTestService(categoryRowTest: .top)))

    return ExploreView(viewModel: ExploreViewModel(container: container))
        .previewEnvironment()
}

#Preview("CategoryRowTest: Hidden") {
    let container = DevPreview.shared.container
    container.register(ABTestManager.self, service: ABTestManager(service: MockABTestService(categoryRowTest: .hidden)))

    return ExploreView(viewModel: ExploreViewModel(container: container))
        .previewEnvironment()
}

#Preview("No Data") {
    let container = DevPreview.shared.container
    container.register(AvatarManager.self, service: AvatarManager(services: MockAvatarServices(remote: MockAvatarService(avatars: [], delay: 3))))

    return ExploreView(viewModel: ExploreViewModel(container: container))
        .previewEnvironment()
}

#Preview("Slow Loading") {
    let container = DevPreview.shared.container
    container.register(AvatarManager.self, service: AvatarManager(services: MockAvatarServices(remote: MockAvatarService(delay: 4))))

    return ExploreView(viewModel: ExploreViewModel(container: container))
        .previewEnvironment()
}
