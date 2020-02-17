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
            List(viewModel.state.images) { image in
                Text(image.id)
            }.onAppear {
                self.viewModel.search("cats")
            }
        }
    }
}

extension Imgur {
    final class ImagesListViewModel: ObservableObject {
        @Published var state = State()
        
        private var tokens: Set<AnyCancellable> = []
        
        func search(_ term: String) {
            Imgur.api.search(term)
                .map { $0.data.compactMap(\.images).flatMap { $0 } }
                .replaceError(with: [])
                .sink { images in
                    self.state.images = images
            }.store(in: &tokens)
        }
        
        struct State {
            var images: [Imgur.Image] = []
        }
    }
}

extension Imgur.Image: Identifiable {}

extension Imgur.Post: Identifiable {}
