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
    
    public enum Error: Swift.Error {
        case connectivity
    }
    
    public init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    public func load() async throws {
        do {
            try await client.data(from: url)
        } catch {
            throw Error.connectivity
        }
    }
}

public protocol HTTPClient {
    func data(from url: URL) async throws
}
