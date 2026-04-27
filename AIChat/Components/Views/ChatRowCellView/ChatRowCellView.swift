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
                        .lineLimit(1)
                        .frame(maxWidth: 225, alignment: .leading)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if isNewMessage {
                Circle()
                    .fill(.accent)
                    .frame(width: 8, height: 8)
                    .padding(.trailing, 20)
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
