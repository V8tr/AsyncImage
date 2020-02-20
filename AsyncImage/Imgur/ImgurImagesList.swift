//
//  ImgurImagesList.swift
//  AsyncImage
//
//  Created by Vadym Bulavin on 2/14/20.
//  Copyright © 2020 Vadym Bulavin. All rights reserved.
//

import SwiftUI
import Combine

extension Imgur {
    struct ImagesList: View {
        @EnvironmentObject var viewModel: ImagesListViewModel
        
        var body: some View {
            Group {
                if self.viewModel.state.images.isEmpty {
                    Spinner(isAnimating: true, style: .large)
                } else {
                    imagesList
                }
            }
            .onAppear {
                self.viewModel.searchImages("trump")
            }
        }
        
        private var imagesList: some View {
            List(viewModel.state.images) { image in
                ImageView(image: image)
                    .frame(minHeight: 100, maxHeight: 100)
            }
        }
    }
    
    struct ImageView: View {
        let image: Imgur.Image
        
        var body: some View {
            image.link.flatMap(URL.init).map {
                AsyncImage(
                    url: $0,
//                    cache: cache,
                    placeholder: spinner,
                    configuration: { $0.resizable().renderingMode(.original) }
                ).aspectRatio(contentMode: .fit)
            }
        }
        
        private var spinner: Spinner {
            Spinner(isAnimating: true, style: .large)
        }
    }
}

extension Imgur {
    final class ImagesListViewModel: ObservableObject {
        @Published var state = State()
        
        private var tokens: Set<AnyCancellable> = []
        
        func searchImages(_ term: String) {
            Imgur.api.search(term)
                .map { $0.data.compactMap(\.images).flatMap { $0 }.filter(\.isImage) }
                .replaceError(with: [])
                .sink { images in self.state.images = images }
                .store(in: &tokens)
        }
        
        func searchMemes() {
            Imgur.api.memes()
                .map { $0.data.compactMap(\.images).flatMap { $0 }.filter(\.isImage) }
                .replaceError(with: [])
                .sink { images in self.state.images = images }
                .store(in: &tokens)
        }
        
        struct State {
            var images: [Imgur.Image] = []
        }
    }
}

extension Imgur.Image: Identifiable {}
extension Imgur.Post: Identifiable {}
