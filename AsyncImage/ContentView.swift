//
//  ContentView.swift
//  AsyncImage
//
//  Created by Vadym Bulavin on 2/13/20.
//  Copyright © 2020 Vadym Bulavin. All rights reserved.
//

import SwiftUI
import Combine

struct ContentView: View {    
    var body: some View {
//        Imgur.ImagesList()
//            .environmentObject(Imgur.ImagesListViewModel())
        MoviesList()
            .environmentObject(MoviesListViewModel())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
