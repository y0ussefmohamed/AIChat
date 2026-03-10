//
//  ChatRowCellView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 09/03/2026.
//

import SwiftUI

struct ChatRowCellView: View {
    var imageName: String? =  Constants.randomImage
    var headline: String? = "Alpha"
    var subheadline: String? = "Hey, how are you?"
    var isNewMessage: Bool = false

    var body: some View {
        HStack {
            ZStack {
                if let imageName = imageName {
                    ImageLoaderView(imageUrlString: imageName)

                } else {
                    Rectangle()
                        .fill(.secondary.opacity(0.5))
                }
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                if let headline = headline {
                    Text(headline)
                        .font(.headline)
                }
                
                if let subheadline = subheadline {
                    Text(subheadline)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if isNewMessage {
                Text("NEW")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(.blue)
                    .cornerRadius(10)
                    .foregroundColor(.white)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(Color(uiColor: .systemBackground))
    }
}

#Preview {
    ZStack {
        Color.gray.ignoresSafeArea()

        List {
            ChatRowCellView()
                .removeListRowFormatting()

            ChatRowCellView(imageName: nil)
                .removeListRowFormatting()

            ChatRowCellView(isNewMessage: true)
                .removeListRowFormatting()

            ChatRowCellView(imageName: nil, isNewMessage: true)
                .removeListRowFormatting()
        }

    }
}
