//
//  HeroCellView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 05/03/2026.
//

import SwiftUI

struct HeroCellView: View {
    var imageName: String? = Constants.randomImage
    var title: String? = "Title is some simple title"
    var subtitle: String? = "Subtitle is some simple subtitle"

    var body: some View {
        ZStack {
            if let imageName {
                ImageLoaderView(imageUrlString: imageName)
            } else {
                Rectangle()
                    .fill(.accent)
            }
        }
        .overlay(
            alignment: .bottomLeading,
            content: {
                VStack(alignment: .leading, spacing: 4) {
                    if let title {
                        Text(title)
                            .font(.headline)
                            .bold()
                    }
                    if let subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    LinearGradient(
                        gradient: Gradient(
                            colors: [
                                Color.black.opacity(0),
                                Color.black.opacity(0.3),
                                Color.black.opacity(0.3)
                            ]
                        ),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .foregroundStyle(.white)
        })
        .cornerRadius(16)
    }
}

#Preview {
    ScrollView {
        HeroCellView()
            .frame(width: 300, height: 200)

        HeroCellView(imageName: nil)
            .frame(width: 300, height: 400)

        HeroCellView(imageName: nil, title: "New Title", subtitle: nil)
            .frame(width: 300, height: 400)
    }
    .scrollIndicators(.never)
}
