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
    @State var cancellables: Set<AnyCancellable> = []
    
    var body: some View {
        Text("Hello, World!")
            .onAppear {
                api
                    .search("cats")
                    .sink(receiveCompletion: { print($0) },
                          receiveValue: { print($0) })
                    .store(in: &self.cancellables)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
