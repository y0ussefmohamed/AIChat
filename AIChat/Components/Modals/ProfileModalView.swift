//
//  ProfileModalView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 14/03/2026.
//

import SwiftUI

struct ProfileModalView: View {
    var imageName: String? = Constants.randomImage
    var title: String? = "Alpha"
    var subtitle: String? = "alien"
    var onXMarkPressed: () -> Void = {}

    var body: some View {
        VStack(spacing: 0) {
            if let imageName {
                ImageLoaderView(imageUrlString: imageName, forceTransitionAnimation: true)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 300)
            }

            VStack(alignment: .leading) {
                if let title {
                    Text(title)
                        .font(.title)
                        .foregroundStyle(Color(uiColor: .label))
                        .fontWeight(.bold)
                }

                if let subtitle {
                    Text(subtitle)
                        .font(.title3)
                        .foregroundStyle(Color(uiColor: .secondaryLabel))
                }
            }
            .padding(.vertical, 10)
            .padding(.leading)
            .frame(width: 300, alignment: .leading)
            .background(
                .thinMaterial
            )
        }
        .overlay(alignment: .topTrailing) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 24))
                .foregroundColor(.white)
                .padding(4)
                .tappableBackground()
                .padding(8)
                .styledButton(.pressable, action: onXMarkPressed)
        }
        .cornerRadius(16)
    }
}

#Preview {
    ZStack {
        Color.accent.ignoresSafeArea()
        ProfileModalView()
    }
}
