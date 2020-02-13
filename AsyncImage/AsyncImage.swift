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
        Image(uiImage: loader.image)
            .onAppear(perform: loader.load)
    }
}
