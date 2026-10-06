//
//  TabBarView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 04/03/2026.
//

import SwiftUI

struct TabBarView: View {
    @Environment(LogManager.self) private var logManager
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(AIManager.self) private var aiManager

    @State private var selectedTab: AppTap = .explore

    var body: some View {
        TabView(selection: $selectedTab) {
            ExploreView()
                .tabItem {
                    Label("Explore", systemImage: "eyes")
                }
                .tag(AppTap.explore)

            UserChatsView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Chats", systemImage: "message")
                }
                .tag(AppTap.chats)

            ProfileView(
                viewModel: ProfileViewModel(
                    logManager: logManager,
                    authManager: authManager,
                    userManager: userManager,
                    avatarManager: avatarManager,
                    aiManager: aiManager
                )
            )
            .tabItem {
                Label("Profile", systemImage: "person.fill")
            }
            .tag(AppTap.profile)
        }
        .screenAppearAnalytics(viewName: "TabBarView")
        .onChange(of: selectedTab) { _, newTab in
            logManager.trackEvent(
                event: TabBarViewEvent.tabSelected(tab: newTab)
            )
        }
    }
}

extension TabBarView {
    enum TabBarViewEvent: LoggableEvent {
        case tabSelected(tab: AppTap)

        var eventName: String {
            switch self {
            case .tabSelected:
                return "TabBarView_Tab_Selected"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .tabSelected(tab: let tab):
                return tab.asEventParameter
            }
        }

        var type: LogType {
            .analytic
        }
    }
}

#Preview {
    TabBarView()
        .previewEnvironment()
}
