//
//  AppView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 03/03/2026.
//

import SwiftUI

struct AppView: View {
    @State private var showTabBar: Bool = false

    var body: some View {
        ZStack {
            if showTabBar {
                ZStack {
                    Color.red.ignoresSafeArea()
                    Text("AAPPPPP")
                }
                .transition(.move(edge: .trailing))
            } else {
                ZStack {
                    Color.blue.ignoresSafeArea()
                    Text("Onboarding")
                }
            }
        }
        .animation(.smooth, value: showTabBar)
        .onTapGesture {
            showTabBar.toggle()
        }
    }
}

#Preview {
    AppView()
}
