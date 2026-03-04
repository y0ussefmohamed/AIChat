//
//  TabBarView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 04/03/2026.
//

import SwiftUI

struct TabBarView: View {
    var body: some View {
        TabView {
            NavigationStack {
                Text("Explore")
                    .navigationTitle("Explore")
            }
            .tabItem {
                Label("Explore", systemImage: "eyes")
            }
            
            NavigationStack {
                Text("Chats")
                    .navigationTitle("Chats")
            }
            .tabItem {
                Label("Chats", systemImage: "message")
            }
            
            NavigationStack {
                Text("Profile")
                    .navigationTitle("Profile")
            }
            .tabItem {
                Label("Profile", systemImage: "person.fill")
            }
        }
    }
}

#Preview {
    TabBarView()
}
