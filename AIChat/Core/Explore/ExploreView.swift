//
//  ExploreView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 04/03/2026.
//

import SwiftUI

struct ExploreView: View {
    let avatar: Avatar = Avatar.mock

    var body: some View {
        NavigationStack {
            VStack {
                HeroCellView(
                    imageName: avatar.profileImageName,
                    title: avatar.name,
                    subtitle: avatar.characterDescription
                )
                .frame(width: 300, height: 200)
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .navigationTitle("Explore")
        }
    }
}

#Preview {
    ExploreView()
}
