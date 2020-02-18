//
//  ImageLoader.swift
//  AsyncImage
//
//  Created by Vadym Bulavin on 2/13/20.
//  Copyright © 2020 Vadym Bulavin. All rights reserved.
//

import Combine
import SwiftUI

struct Cache {
    let `get`: (URL) -> UIImage?
    let `set`: (UIImage, URL) -> Void
    
    static let null = Cache(get: { _ in nil }, set: { _, _ in })
    
    static let nsCache = Cache(get: {
        NSCache<NSString, UIImage>().object(forKey: $0.absoluteString as NSString)
    }, set: { _, _ in })
}

class ImageLoader: ObservableObject {
    @Published var image: UIImage?

    private let url: URL
    private let cache: Cache
    private var cancellable: AnyCancellable?
    
    init(url: URL, cache: Cache = .null) {
        self.url = url
        self.cache = cache
    }
    
    func load() {
        image = cache.get(url)
        
        cancellable = URLSession.shared
            .dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { image in
                image.map { [url = self.url] in self.cache.set($0, url) } // Check for retain cycle
            })
            .assign(to: \.image, on: self)
    }
    
    func cancel() {
        cancellable?.cancel()
    }
}
