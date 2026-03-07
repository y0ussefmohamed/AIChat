//
//  ImageLoaderView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 04/03/2026.
//

import SwiftUI
import SDWebImageSwiftUI

struct ImageLoaderView: View {
    var imageUrlString: String = Constants.randomImage
    var resizingMode: ContentMode = .fill

    var body: some View {
        Rectangle().opacity(0) /// use this to frame the image better
            .overlay {
                WebImage(url: URL(string: imageUrlString))
                    .resizable()
                    .indicator(.activity)
                    .aspectRatio(contentMode: resizingMode)
                    .allowsHitTesting(false) /// not clickable
            }
            .clipped() /// take the rectangle frame
    }
}

#Preview {
    ImageLoaderView()
        .frame(width: 300, height: 300)
}
