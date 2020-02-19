//
//  AsyncImage.swift
//  AsyncImage
//
//  Created by Vadym Bulavin on 2/13/20.
//  Copyright © 2020 Vadym Bulavin. All rights reserved.
//

import SwiftUI

//struct AsyncImage<Placeholder: View>: View {
//    @ObservedObject private var loader: ImageLoader
//    private var placeholder: Placeholder?
//
//    init(url: URL, placeholder: Placeholder? = nil) {
//        self.placeholder = placeholder
//        loader = ImageLoader(url: url)
//    }
//
//    var body: some View {
//        image
//            .onAppear(perform: loader.load)
//    }
//
//    private var image: some View {
//        Group {
//            if loader.image != nil {
//                loader.image.map(Image.init(uiImage:))?
//                    .resizable()
//                    .renderingMode(.original)
//                    .aspectRatio(contentMode: .fit)
//            } else if placeholder != nil {
//                placeholder
//            } else {
//                EmptyView()
//            }
//        }
//    }
//}

struct AsyncImage<Placeholder: View>: View {
    @ObservedObject var loader: ImageLoader
    let placeholder: Placeholder?
    let configuration: (Image) -> Image
    
    init(url: URL, cache: ImageCache? = nil, placeholder: Placeholder? = nil, configuration: @escaping (Image) -> Image) {
        loader = .loader(url: url, cache: cache)
        self.placeholder = placeholder
        self.configuration = configuration
    }
    
    var body: some View {
        image
            .onAppear(perform: loader.load)
            .onDisappear(perform: loader.cancel)
    }
    
    private var image: some View {
        Group {
            if loader.image != nil {
                configuration(Image(uiImage: loader.image!))
            } else if placeholder != nil {
                placeholder
            } else {
                EmptyView()
            }
        }
    }
}

extension AsyncImage: Equatable {
    static func
}
