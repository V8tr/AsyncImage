//
//  ImageLoader.swift
//  AsyncImage
//
//  Created by Vadym Bulavin on 2/13/20.
//  Copyright © 2020 Vadym Bulavin. All rights reserved.
//

import Combine
import SwiftUI

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    
    private let url: URL
    private var cache: ImageCache?
    private var cancellable: AnyCancellable?
    
    private var isRunning: Bool { Self.activeLoaders[url] != nil }
    private var count = 0
    private static var count = 0
    private static var activeLoaders: [URL: ImageLoader] = [:]
    private static let imageProcessingQueue = DispatchQueue(label: "image-processing")
    
    static func loader(url: URL, cache: ImageCache? = nil) -> ImageLoader {
        return activeLoaders[url, default: ImageLoader(url: url, cache: cache)]
        
//        if let loader = activeLoaders[url] {
//            return loader
//        } else {
//            let loader = ImageLoader(url: url, cache: cache)
//            activeLoaders[url] = loader
//            return loader
//        }
    }
    
    private init(url: URL, cache: ImageCache? = nil) {
        self.url = url
        self.cache = cache
    }
    
    func load() {
        if let image = cache?[url] {
            print("🏎 Loaded from cache \(url)")
            self.image = image
            return
        }
        
        guard !isRunning else { return }
        
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .handleEvents(receiveSubscription: onReceiveSubscription,
                          receiveOutput: { [unowned self] in self.cache($0) },
                          receiveCompletion: { _ in self.onReceiveCompletion() },
                          receiveCancel: onReceiveCancel)
            .subscribe(on: Self.imageProcessingQueue)
            .receive(on: DispatchQueue.main)
            .assign(to: \.image, on: self)
    }
    
    private func onReceiveSubscription(_ subscription: Subscription) {
        Self.activeLoaders[url] = self
        Self.count += 1
        count += 1
        log(label: "Start")
    }
    
    private func onReceiveCompletion() {
        Self.count -= 1
        count += 1
        log(label: "Loaded")
        Self.activeLoaders[url] = nil
    }
    
    private func onReceiveCancel() {
        Self.count -= 1
        count -= 1
        log(label: "Cancel")
        Self.activeLoaders[url] = nil
    }
    
    private func log(label: String) {
        print("🏎 \(label) \(self.url) total \(Self.count) self \(count)")
    }
    
    func cancel() {
        cancellable?.cancel()
    }
    
    private func cache(_ image: UIImage?) {
        assert(image != nil)
        log(label: "Cache")
        image.map { cache?[url] = $0 }
    }
}
