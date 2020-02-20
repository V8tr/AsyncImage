//
//  Steps.swift
//  AsyncImage
//
//  Created by Vadym Bulavin on 2/20/20.
//  Copyright © 2020 Vadym Bulavin. All rights reserved.
//

import SwiftUI
import Combine
import Foundation

enum Step1 {
    
    class ImageLoader: ObservableObject {
        @Published var image: UIImage?
        private let url: URL

        init(url: URL) {
            self.url = url
        }
        
        func load() {
            
        }
        
        func cancel() {
            
        }
    }
    
    struct AsyncImage<Placeholder: View>: View {
        @ObservedObject var loader: ImageLoader
        private let placeholder: Placeholder?
        
        init(url: URL, placeholder: Placeholder? = nil) {
            loader = ImageLoader(url: url)
            self.placeholder = placeholder
        }

        var body: some View {
            image
                .onAppear(perform: loader.load)
                .onDisappear(perform: loader.cancel)
        }
        
        private var image: some View {
            placeholder
        }
    }
}
