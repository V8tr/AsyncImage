//
//  ContentView.swift
//  AsyncImage
//
//  Created by Vadym Bulavin on 2/13/20.
//  Copyright © 2020 Vadym Bulavin. All rights reserved.
//

import SwiftUI

let posters = [
    "https://image.tmdb.org/t/p/original//pThyQovXQrw2m0s9x82twj48Jq4.jpg",
    "https://image.tmdb.org/t/p/original//vqzNJRH4YyquRiWxCCOH0aXggHI.jpg",
    "https://image.tmdb.org/t/p/original//6ApDtO7xaWAfPqfi2IARXIzj8QS.jpg",
    "https://image.tmdb.org/t/p/original//7GsM4mtM0worCtIVeiQt28HieeN.jpg"
].map { URL(string: $0)! }

struct ContentView: View {
    var body: some View {
         List(posters, id: \.self) { url in
             AsyncImage(
                url: url,
                placeholder: { Text("Loading ...") },
                image: { Image(uiImage: $0).resizable() }
             )
            .frame(idealHeight: UIScreen.main.bounds.width / 2 * 3) // 2:3 aspect ratio
         }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
