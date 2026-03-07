//
//  CategoryCellView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 07/03/2026.
//

import SwiftUI

struct CategoryCellView: View {
    var title: String = "Men"
    var imageName: String = Constants.randomImage
    var font: Font = .title2
    var cornerRadius: CGFloat = 16

    var body: some View {
        ImageLoaderView(imageUrlString: imageName)
        .aspectRatio(1, contentMode: .fit) /// for it to be a square using a width or a height
        .overlay(alignment: .bottomLeading) {
            Text(title)
                .font(font)
                .fontWeight(.semibold)
                .padding(16)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .visibleGradientBackground()
        }
        .cornerRadius(cornerRadius)
    }
}

#Preview {
    CategoryCellView()
        .frame(width: 150)
}
