//
//  ImgurDemoList.swift
//  AsyncImage
//
//  Created by Vadym Bulavin on 2/14/20.
//  Copyright © 2020 Vadym Bulavin. All rights reserved.
//

import SwiftUI

extension Imgur.Image: Identifiable {}
extension Imgur.Post: Identifiable {}

struct ImgurDemoListContainer: View {
    var body: some View {
        EmptyView()
    }
}

struct ImgurDemoList: View {
    let images: [Imgur.Image]
    
    var body: some View {
        List(images) { image in
            Text(image.id)
        }
    }
}
