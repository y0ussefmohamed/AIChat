//
//  TabBarView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 04/03/2026.
//

import SwiftUI

enum AppTap {
      case explore
      case chats
      case profile
}

struct TabBarView: View {
    @State private var selectedTab: AppTap = .explore

    var body: some View {
        TabView(selection: $selectedTab) {
            ExploreView()
                .tabItem {
                    Label("Explore", systemImage: "eyes")
                }
                .tag(AppTap.explore)

            ChatsView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Chats", systemImage: "message")
                }
                .tag(AppTap.chats)

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(AppTap.profile)
        }
    }
}

#Preview {
    TabBarView()
}
