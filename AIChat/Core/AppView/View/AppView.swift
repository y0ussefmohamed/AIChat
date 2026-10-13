//
//  AppView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 03/03/2026.
//

import SwiftUI
import SwiftfulUtilities

struct AppView: View {
    @Environment(DependencyContainer.self) private var container
    @State var viewModel: AppViewModel

    var body: some View {
        RootView(
            delegate: RootDelegate(
                onApplicationDidAppear: nil,
                onApplicationWillEnterForeground: { _ in
                    Task {
                        await viewModel.checkUserStatus()
                    }
                },
                onApplicationDidBecomeActive: nil,
                onApplicationWillResignActive: nil,
                onApplicationDidEnterBackground: nil,
                onApplicationWillTerminate: nil)
        ) {
            AppViewBuilder(
                showTabBar: viewModel.showTabBar,
                tabbarView: {
                    TabBarView()
                },
                onboardingView: {
                    WelcomeView(viewModel: WelcomeViewModel(interactor: CoreInteractor(container: container)))
            })
            .screenAppearAnalytics(viewName: "AppView")
            .task {
                await viewModel.checkUserStatus()
            }
            .task {
                await viewModel.showATTPromptIfNeeded()
            }
            .onChange(of: viewModel.showTabBar) { _, showTabBar in
                /// if user signedOut\deletedAccount then create a new anonymous account
                if !showTabBar {
                    Task {
                        await viewModel.checkUserStatus()
                    }
                }
            }
        }
    }
}

#Preview("Tabbar") {
    let container = DevPreview.shared.container
    container.register(AppState.self, service: AppState(showTabBar: true))

    return AppView(
        viewModel: AppViewModel(
            interactor: CoreInteractor(
                container: container
            )
        )
    )
    .previewEnvironment()
    .environment(container)
}

#Preview("Onboarding") {
    let container = DevPreview.shared.container
    container.register(AppState.self, service: AppState(showTabBar: false))

    return AppView(
        viewModel: AppViewModel(
            interactor: CoreInteractor(
                container: container
            )
        )
    )
    .previewEnvironment()
    .environment(container)
}
