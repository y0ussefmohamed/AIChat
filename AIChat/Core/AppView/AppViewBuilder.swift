//
//  AppViewBuilder.swift
//  AIChat
//
//  Created by Youssef Mohamed on 04/03/2026.
//

import Foundation
import SwiftUI

/// This decouples the AppView from a specific tabbar and onboarding view
struct AppViewBuilder<TabbarView: View, OnboardingView: View>: View {
    var showTabBar: Bool = false

    @ViewBuilder var tabbarView: TabbarView
    @ViewBuilder var onboardingView: OnboardingView

    var body: some View {
        ZStack {
            if showTabBar {
                tabbarView
                .transition(.move(edge: .trailing))
            } else {
                onboardingView
            }
        }
        .animation(.smooth, value: showTabBar)
    }
}

private struct PreviewView: View {
    var showTabBar: Bool = false

    var body: some View {
        AppViewBuilder(
            showTabBar: showTabBar,
            tabbarView: {
                return ZStack {
                    Color.red.ignoresSafeArea()
                    Text("Tabbar View")
                }
            },
            onboardingView: {
                ZStack {
                    Color.blue.ignoresSafeArea()
                    Text("Onboarding View")
            }
        })
    }
}

#Preview("AppView - Tabbar") {
    PreviewView(showTabBar: true)
}

#Preview("AppView - Onboarding") {
    PreviewView(showTabBar: false)
}
