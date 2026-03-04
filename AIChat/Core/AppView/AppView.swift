//
//  AppView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 03/03/2026.
//

import SwiftUI

struct AppView: View {
    @State var appState: AppState = AppState()

    var body: some View {
        AppViewBuilder(
            showTabBar: appState.showTabBar,
            tabbarView: {
                TabBarView()
            },
            onboardingView: {
                WelcomeView()
        })
        /// you can get access to this specific appState obj. using `@Envirnonment(AppState.self)`
        .environment(appState) /// this will be in the views that has `AppView` as parent/ancestor
    }
}

#Preview("Onboarding") {
    AppView(appState: AppState(showTabBar: false))
}

#Preview("Tabbar") {
    AppView(appState: AppState(showTabBar: true))
}
