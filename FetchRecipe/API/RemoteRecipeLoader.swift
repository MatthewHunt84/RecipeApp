//
//  Untitled.swift
//  FetchRecipe
//
//  Created by Matt Hunt on 2/10/25.
//

import Foundation

public struct RemoteRecipeLoader {
    
    let client: HTTPClient
    let url: URL
    
    public init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    public func load() {
        client.data(from: url)
    }
}

public protocol HTTPClient {
    func data(from url: URL)
}
