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
    
    private static var activeLoaders: [URL: ImageLoader] = [:]
    private static let imageProcessingQueue = DispatchQueue(label: "image-processing")
    
    static func loader(url: URL, cache: ImageCache? = nil) -> ImageLoader {
        return activeLoaders[url, default: ImageLoader(url: url, cache: cache)]
    }
    
    private init(url: URL, cache: ImageCache? = nil) {
        self.url = url
        self.cache = cache
    }
    
    func load() {
        guard !isRunning else { return }

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
            .subscribe(on: Self.imageProcessingQueue)
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
