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
    @State var appState: AppState = AppState()

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
                showTabBar: appState.showTabBar,
                tabbarView: {
                    TabBarView()
                },
                onboardingView: {
                    WelcomeView(viewModel: WelcomeViewModel(interactor: CoreInteractor(container: container)))
            })
            /// you can get access to this specific appState obj. using `@Envirnonment(AppState.self)`
            .environment(appState) /// this will be in the views that has `AppView` as parent/ancestor
            .screenAppearAnalytics(viewName: "AppView")
            .task {
                await viewModel.checkUserStatus()
            }
            .task {
                await viewModel.showATTPromptIfNeeded()
            }
            .onChange(of: appState.showTabBar) { _, showTabBar in
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

    return AppView(
        viewModel: AppViewModel(interactor: CoreInteractor(container: container)),
        appState: AppState(showTabBar: true)
    )
    .previewEnvironment()
    .environment(container)
}

#Preview("Onboarding") {
    let container = DevPreview.shared.container

    return AppView(
        viewModel: AppViewModel(interactor: CoreInteractor(container: container)),
        appState: AppState(showTabBar: false)
    )
    .previewEnvironment()
    .environment(container)
}
