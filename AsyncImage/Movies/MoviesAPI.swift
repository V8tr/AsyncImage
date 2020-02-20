//
//  MoviesAPI.swift
//  AsyncImage
//
//  Created by Vadym Bulavin on 2/20/20.
//  Copyright © 2020 Vadym Bulavin. All rights reserved.
//

import Foundation
import Combine

enum Movies {}

extension Movies {
    enum API {
        static let imageBase = URL(string: "https://image.tmdb.org/t/p/original/")!

        private static let base = URL(string: "https://api.themoviedb.org/3")!
        private static let apiKey = "efb6cac7ab6a05e4522f6b4d1ad0fa43"
        private static let agent = Agent()
        
        static func trending() -> AnyPublisher<Page<Movie>, Error> {
            var components = URLComponents(url: base.appendingPathComponent("trending/movie/week"), resolvingAgainstBaseURL: true)!
            components.queryItems = [URLQueryItem(name: "api_key", value: apiKey)]
            let request = URLRequest(url: components.url!)
            return agent.run(request)
        }
    }
}

extension Movies {
    struct Page<T: Codable>: Codable {
        let page: Int?
        let total_results: Int?
        let total_pages: Int?
        let results: [T]
    }
    
    struct Movie: Codable {
        let id: Int
        let title: String
        let poster_path: String?
        
        var poster: URL? {
            return poster_path.map { API.imageBase.appendingPathComponent($0) }
        }
    }
}
