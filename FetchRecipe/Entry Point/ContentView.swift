//
//  ContentView.swift
//  FetchRecipe
//
//  Created by Matt Hunt on 2/7/25.
//

import SwiftUI

struct MultiplatformContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    MultiplatformContentView()
}
