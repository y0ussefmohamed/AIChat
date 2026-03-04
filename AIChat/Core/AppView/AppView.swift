//
//  AppView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 03/03/2026.
//

import SwiftUI

struct AppView: View {
    @AppStorage("showTabbarView") var showTabBar: Bool = false

    var body: some View {
        AppViewBuilder(
            showTabBar: showTabBar,
            tabbarView: {
                return ZStack {
                    Color.blue.ignoresSafeArea()
                    Text("Tabbar View")
                }
            },
            onboardingView: {
                ZStack {
                    Color.red.ignoresSafeArea()
                    Text("Onboarding View")
            }
        })
    }
}

#Preview("AppView - Tabbar") {
    AppView(showTabBar: true)
}

#Preview("AppView - Onboarding") {
    AppView(showTabBar: false)
}
