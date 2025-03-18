//
//  YouTubeView.swift
//  FetchRecipe
//
//  Created by Matt Hunt on 3/17/25.
//

import UIKit
import SwiftUI
import WebKit

struct YouTubePlayerView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.configuration.allowsInlinePredictions = true
        webView.configuration.mediaTypesRequiringUserActionForPlayback = []
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}

struct YouTubeView: View {
    let url: URL
    let title: String
    var body: some View {
        VStack {
            YouTubePlayerView(url: url)
        }
        .background(.blue.gradient)
        .navigationTitle(title)
    }
}
