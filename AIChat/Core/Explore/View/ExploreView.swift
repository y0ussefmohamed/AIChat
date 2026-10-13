//
//  ExploreView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 04/03/2026.
//

import SwiftUI

struct ExploreView: View {
    @Environment(DependencyContainer.self) private var container
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
                DevSettingsView(
                    viewModel: DevSettingsViewModel(
                        interactor: CoreInteractor(container: container)
                    )
                )
            }
            .sheet(isPresented: $viewModel.showCreateAccountView) {
                LinkProviderView(
                    viewModel: LinkProviderViewModel(
                        interactor: CoreInteractor(container: container),
                        usageOption: .createAccount
                    )
                )
            }
            .navigationDestination(for: NavigationPathOption.self) { pathOptionTop in
                switch pathOptionTop {
                case .chat(let avatarId):
                    ChatView(viewModel: ChatViewModel(interactor: CoreInteractor(container: container), avatarId: avatarId))
                case .category(let category, let imageName):
                    CategoryListView(viewModel: CategoryListViewModel(interactor: CoreInteractor(container: container)), category: category, categoryImageName: imageName, navPathStack: $viewModel.navPathStack)
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
    ExploreView(viewModel: ExploreViewModel(interactor: CoreInteractor(container: DevPreview.shared.container)))
        .previewEnvironment()
}

#Preview("Has Data w/ Create Acc Test") {
    let container = DevPreview.shared.container
    container.register(AuthManager.self, service: AuthManager(
        service: MockAuthService(user: .mock(isAnonymous: true)),
        logManager: DevPreview.shared.logManager
    ))
    container.register(ABTestManager.self, service: ABTestManager(service: MockABTestService(createAccountTest: true)))

    return ExploreView(viewModel: ExploreViewModel(interactor: CoreInteractor(container: container)))
        .previewContainerEnvironment()
        .previewEnvironment()
}

#Preview("CategoryRowTest: Original") {
    let container = DevPreview.shared.container
    container.register(
        ABTestManager.self,
        service: ABTestManager(
            service: MockABTestService(categoryRowTest: .original)
        )
    )

    return ExploreView(
        viewModel: ExploreViewModel(
            interactor: CoreInteractor(container: container)
        )
    )
    .previewEnvironment()
}


#Preview("CategoryRowTest: Top") {
    let container = DevPreview.shared.container
    container.register(ABTestManager.self, service: ABTestManager(service: MockABTestService(categoryRowTest: .top)))

    return ExploreView(viewModel: ExploreViewModel(interactor: CoreInteractor(container: container)))
        .previewEnvironment()
}

#Preview("CategoryRowTest: Hidden") {
    let container = DevPreview.shared.container
    container.register(ABTestManager.self, service: ABTestManager(service: MockABTestService(categoryRowTest: .hidden)))

    return ExploreView(viewModel: ExploreViewModel(interactor: CoreInteractor(container: container)))
        .previewEnvironment()
}

#Preview("No Data") {
    let container = DevPreview.shared.container
    container.register(AvatarManager.self, service: AvatarManager(services: MockAvatarServices(remote: MockAvatarService(avatars: [], delay: 3))))

    return ExploreView(viewModel: ExploreViewModel(interactor: CoreInteractor(container: container)))
        .previewEnvironment()
}

#Preview("Slow Loading") {
    let container = DevPreview.shared.container
    container.register(AvatarManager.self, service: AvatarManager(services: MockAvatarServices(remote: MockAvatarService(delay: 4))))

    return ExploreView(viewModel: ExploreViewModel(interactor: CoreInteractor(container: container)))
        .previewEnvironment()
}
