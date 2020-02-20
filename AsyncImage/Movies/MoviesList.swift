//
//  MoviesList.swift
//  AsyncImage
//
//  Created by Vadym Bulavin on 2/20/20.
//  Copyright © 2020 Vadym Bulavin. All rights reserved.
//

import Combine
import SwiftUI

let cache = ImageCacheImpl()

final class MoviesListViewModel: ObservableObject {
    @Published var state = State()
    
    private var tokens: Set<AnyCancellable> = []
    
    func search(_ term: String) {
        Movies.API.search(term)
            .map(\.results)
            .replaceError(with: [])
            .assign(to: \.state.movies, on: self)
            .store(in: &tokens)
    }
    
    func searchTrending() {
        Movies.API.trending()
            .map(\.results)
            .replaceError(with: [])
            .assign(to: \.state.movies, on: self)
            .store(in: &tokens)
    }
    
    struct State {
        var movies: [Movies.Movie] = []
    }
}

struct MoviesList: View {
    @EnvironmentObject var viewModel: MoviesListViewModel
    
    var body: some View {
        Group {
            if self.viewModel.state.movies.isEmpty {
                Spinner(isAnimating: true, style: .large)
            } else {
                movies
            }
        }
        .onAppear { self.viewModel.searchTrending() }
    }
    
    private var movies: some View {
        List(viewModel.state.movies, rowContent: MovieView.init)
    }
}

struct MovieView: View {
    let movie: Movies.Movie
    
    var body: some View {
        VStack {
            title
            poster
        }
    }
    
    private var title: some View {
        Text(movie.title)
            .frame(idealWidth: .infinity, maxWidth: .infinity, alignment: .center)
    }
    
    private var poster: some View {
        movie.poster.map { url in
            AsyncImage(
                url: url,
                cache: cache,
                placeholder: spinner,
                configuration: { $0.resizable().renderingMode(.original) }
            ).aspectRatio(contentMode: .fit)
        }
    }
    
    private var spinner: some View {
        Spinner(isAnimating: true, style: .large)
    }
}

extension Movies.Movie: Identifiable {}
