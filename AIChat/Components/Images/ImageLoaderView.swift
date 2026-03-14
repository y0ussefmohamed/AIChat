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
    var forceTransitionAnimation: Bool = false

    var body: some View {
        Rectangle().opacity(0.001) /// use this to frame the image better
            .overlay {
                WebImage(url: URL(string: imageUrlString))
                    .resizable()
                    .indicator(.activity)
                    .aspectRatio(contentMode: resizingMode)
                    .allowsHitTesting(false) /// not clickable
            }
            .clipped() /// take the rectangle frame
            /// if the Bool is true then it will execute the action func else it will do nothing
            .ifSatisfiedCondition(forceTransitionAnimation) { selfContent in
                selfContent /// line 17 to line 25 is the selfContent
                    .drawingGroup() /// forces the image to load before showing
            }
    }
}

#Preview {
    ImageLoaderView()
        .frame(width: 300, height: 300)
}
