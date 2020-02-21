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
        @ObservedObject private var loader: ImageLoader
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

enum Step2 {
    
    class ImageLoader: ObservableObject {
        @Published var image: UIImage?
        private let url: URL
        private var cancellable: AnyCancellable?

        init(url: URL) {
            self.url = url
        }
        
        func load() {
            cancellable = URLSession.shared.dataTaskPublisher(for: url)
                .delay(for: .seconds(2), scheduler: DispatchQueue.main)
                .map { UIImage(data: $0.data) }
                .replaceError(with: nil)
                .receive(on: DispatchQueue.main)
                .assign(to: \.image, on: self)
        }
        
        func cancel() {
            cancellable?.cancel()
        }
    }
    
    struct AsyncImage<Placeholder: View>: View {
        @ObservedObject private var loader: ImageLoader
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
            Group {
                if loader.image != nil {
                    Image(uiImage: loader.image!)
                        .resizable()
                } else {
                    placeholder
                }
            }
        }
    }
    
    struct ContentView: View {
        let url = URL(string: "https://www.vadimbulavin.com/assets/images/posts/async-image-swiftui/cover.png")!
        
        var body: some View {
            AsyncImage(
                url: url,
                placeholder: Text("Loading ...")
            ).aspectRatio(contentMode: .fit)
        }
    }
}

enum Step3 {
    class ImageLoader: ObservableObject {
        @Published var image: UIImage?
        private let url: URL
        private var cancellable: AnyCancellable?
        private var cache: ImageCache?

        init(url: URL, cache: ImageCache? = nil) {
            self.url = url
            self.cache = cache
        }
        
        func load() {
            if let image = cache?[url] {
                self.image = image
                return
            }
            
            cancellable = URLSession.shared.dataTaskPublisher(for: url)
                .map { UIImage(data: $0.data) }
                .replaceError(with: nil)
                .handleEvents(receiveOutput: { [unowned self] in self.cache($0) })
                .receive(on: DispatchQueue.main)
                .assign(to: \.image, on: self)
        }
        
        func cancel() {
            cancellable?.cancel()
        }
        
        private func cache(_ image: UIImage?) {
            image.map { cache?[url] = $0 }
        }
    }
    
    struct AsyncImage<Placeholder: View>: View {
        @ObservedObject private var loader: ImageLoader
        private let placeholder: Placeholder?
        
        init(url: URL, placeholder: Placeholder? = nil, cache: ImageCache? = nil) {
            loader = ImageLoader(url: url, cache: cache)
            self.placeholder = placeholder
        }

        var body: some View {
            image
                .onAppear(perform: loader.load)
                .onDisappear(perform: loader.cancel)
        }
        
        private var image: some View {
            Group {
                if loader.image != nil {
                    Image(uiImage: loader.image!)
                        .resizable()
                } else {
                    placeholder
                }
            }
        }
    }
    
    struct ContentView: View {
        let url = URL(string: "https://www.vadimbulavin.com/assets/images/posts/async-image-swiftui/cover.png")!
        let cache = TemporaryImageCache()
        @State var numberOfRows = 0

        var body: some View {
            NavigationView {
                list
                    .navigationBarItems(trailing: addButton)
            }
        }
        
        private var list: some View {
            List(0..<numberOfRows, id: \.self) { _ in
                self.image
            }
        }

        private var image: some View {
            AsyncImage(
                url: url,
                placeholder: Text("Loading ..."),
                cache: self.cache
            ).frame(minHeight: 200, maxHeight: 200)
        }

        private var addButton: some View {
            Button(action: { self.numberOfRows += 1 }) { Image(systemName: "plus") }
        }
    }
}

enum Step4 {
    class ImageLoader: ObservableObject {
        @Published var image: UIImage?
        
        var isLoading: Bool { Self.activeLoaders[url] != nil }
        
        private let url: URL
        private var cache: ImageCache?
        private var cancellable: AnyCancellable?
        
        private static var activeLoaders: [URL: ImageLoader] = [:]
        
        static func loader(url: URL, cache: ImageCache? = nil) -> ImageLoader {
            return activeLoaders[url, default: ImageLoader(url: url, cache: cache)]
        }
        
        private init(url: URL, cache: ImageCache? = nil) {
            self.url = url
            self.cache = cache
        }
        
        func load() {
            guard !isLoading else { return }

            if let image = cache?[url] {
                self.image = image
                return
            }
            
            cancellable = URLSession.shared.dataTaskPublisher(for: url)
                .map { UIImage(data: $0.data) }
                .replaceError(with: nil)
                .handleEvents(receiveSubscription: { [unowned self] _ in self.onStart() },
                              receiveOutput: { [unowned self] in self.cache($0) },
                              receiveCompletion: { [unowned self] _ in self.onFinish() },
                              receiveCancel: { [unowned self] in self.onFinish() })
                .receive(on: DispatchQueue.main)
                .assign(to: \.image, on: self)
        }
        
        func cancel() {
            cancellable?.cancel()
        }
        
        private func onStart() {
            Self.activeLoaders[url] = self
        }
        
        private func onFinish() {
            Self.activeLoaders[url] = nil
        }
        
        private func cache(_ image: UIImage?) {
            image.map { cache?[url] = $0 }
        }
    }
}
