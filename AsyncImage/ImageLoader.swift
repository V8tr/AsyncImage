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
    private let cache: (UIImage, URL) -> Void
    private var cancellable: AnyCancellable?
    
    init(url: URL, cache: @escaping (UIImage, URL) -> Void = { _, _ in }) {
        self.url = url
        self.cache = cache
    }
    
    func load() {
        cancellable = URLSession.shared
            .dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { image in
                image.map { [url = self.url] in self.cache($0, url) } // Check for retain cycle
            })
            .assign(to: \.image, on: self)
    }
    
    func cancel() {
        cancellable?.cancel()
    }
}
