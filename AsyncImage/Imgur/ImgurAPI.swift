//
//  ImgurAPI.swift
//  AsyncImage
//
//  Created by Vadym Bulavin on 2/14/20.
//  Copyright © 2020 Vadym Bulavin. All rights reserved.
//

import Foundation
import Combine

enum Imgur {}

extension Imgur {
    static let api = API()
    
    struct API {
        let clientId = "1e9f9a6daf86715"
        var session = URLSession.shared
        
        func search(_ query: String) -> AnyPublisher<SearchResponse, Error> {
            let url = URL(string: "https://api.imgur.com/3/gallery/search?q=\(query)")!
            return request(URLRequest(url: url))
        }
        
        func memes() -> AnyPublisher<SearchResponse, Error> {
            let url = URL(string: "https://api.imgur.com/3/g/memes/viral/0.json")!
            return request(URLRequest(url: url))
        }
                
        private func request<T: Decodable>(_ request: URLRequest) -> AnyPublisher<T, Error> {
            var request = request
            request.allHTTPHeaderFields = ["Authorization": "Client-ID \(clientId)"]
            
            return session
                .dataTaskPublisher(for: request)
                .handleEvents(receiveOutput: { print($0.data.prettyPrintedJSONString!) })
                .map(\.data)
                .decode(type: T.self, decoder: JSONDecoder())
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
    }
}

extension Imgur {
    struct SearchResponse: Decodable {
        let data: [Post]
    }
    
    struct Post: Decodable {
        let id: String
        let title: String?
        let images: [Image]?
    }

    struct Image: Decodable {
//        let id: String
        let id = UUID()
        let link: String?
        let type: String?
        
        var isImage: Bool { type == "image/png" }
    }
}

private extension Data {
    var prettyPrintedJSONString: NSString? {
//        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
//              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
//              let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }

        return NSString(data: self, encoding: String.Encoding.utf8.rawValue)
    }
}
