//
//  MoviesList.swift
//  AsyncImage
//
//  Created by Vadym Bulavin on 2/20/20.
//  Copyright © 2020 Vadym Bulavin. All rights reserved.
//

import Combine
import SwiftUI

let cache = TemporaryImageCache()

final class MoviesListViewModel: ObservableObject {
    @Published var state = State()
    
    private var tokens: Set<AnyCancellable> = []

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
    
    private var isLoading: Bool { self.viewModel.state.movies.isEmpty }
    
    private var moviesList: some View {
        List(viewModel.state.movies) { movie in
            MovieView(movie: movie)
        }
    }
    
    private var spinner: some View { Spinner(isAnimating: true, style: .large) }
    
    var body: some View {
        Group {
            if isLoading {
                spinner
            } else {
                moviesList
            }
        }
        .onAppear(perform: self.viewModel.searchTrending)
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
            .font(.title)
            .frame(idealWidth: .infinity, maxWidth: .infinity, alignment: .center)
    }
    
    private var poster: some View {
        movie.poster.map { url in
            AsyncImage(
                url: url,
                cache: cache,
                placeholder: spinner,
                configuration: { $0.resizable().renderingMode(.original) }
            )
        }
        .aspectRatio(contentMode: .fit)
        .frame(idealHeight: UIScreen.main.bounds.width / 2 * 3) // 2:3 aspect ratio
    }
    
    private var spinner: some View {
        Spinner(isAnimating: true, style: .medium)
    }
}

extension Movies.Movie: Identifiable {}
