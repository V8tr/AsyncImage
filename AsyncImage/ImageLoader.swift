//
//  ImageLoader.swift
//  AsyncImage
//
//  Created by Vadym Bulavin on 2/13/20.
//  Copyright © 2020 Vadym Bulavin. All rights reserved.
//

import Combine
import SwiftUI

protocol ImageCache {
    func set(image: UIImage, forKey: URL)
    func image(forKey: URL) -> UIImage?
}

struct ImageCacheImpl: ImageCache {
    let cache = NSCache<NSURL, UIImage>()
    
    func set(image: UIImage, forKey key: URL) {
        cache.setObject(image, forKey: key as NSURL)
    }
    
    func image(forKey key: URL) -> UIImage? {
        return cache.object(forKey: key as NSURL)
    }
}

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    
    static var count = 0

    private let url: URL
    private let cache: ImageCache?
    private var cancellable: AnyCancellable?
    
    init(url: URL, cache: ImageCache? = nil) {
        self.url = url
        self.cache = cache
    }
    
    func load() {
        if let image = cache?.image(forKey: url) {
            print("Loaded from cache \(url)")
            self.image = image
            return
        }
        
        cancellable = URLSession.shared
            .dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .handleEvents(receiveSubscription: { _ in Self.count += 1; print("Start \(self.url) total \(Self.count)") },
                          receiveCompletion: { _ in Self.count -= 1; print("Loaded \(self.url) total \(Self.count)") },
                          receiveCancel: { Self.count -= 1; print("Cancel \(self.url) total \(Self.count)") })
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { image in
                image.map { self.cache?.set(image: $0, forKey: self.url) } // Check for retain cycle
            })
            .assign(to: \.image, on: self)
    }
    
    func cancel() {
        cancellable?.cancel()
    }
}
