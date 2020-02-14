//
//  AsyncImage.swift
//  AsyncImage
//
//  Created by Vadym Bulavin on 2/13/20.
//  Copyright © 2020 Vadym Bulavin. All rights reserved.
//

import SwiftUI

struct AsyncImage: View {
    @ObservedObject private var loader: ImageLoader
    private let placeholder: AnyView?
    
    init(url: URL, placeholder: AnyView? = nil) {
        self.placeholder = placeholder
        loader = ImageLoader(url: url)
    }
    
    var body: some View {
        image
            .onAppear(perform: loader.load)
            .onDisappear(perform: loader.cancel)
    }
    
    private var image: some View {
        Group {
            if loader.image != nil {
                loader.image.map(Image.init(uiImage:))
            } else if placeholder != nil {
                placeholder
            } else {
                EmptyView()
            }
        }
    }
}
