//
//  Untitled.swift
//  FetchRecipe
//
//  Created by Matt Hunt on 2/10/25.
//

import Foundation

public protocol HTTPClient {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

public struct RemoteRecipeLoader {
    
    let client: HTTPClient
    let url: URL
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidStatusCode
        case invalidHTTPResponse
        case invalidData
        case decodingError
    }
    
    public init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    public func load() async throws -> [Recipe] {
        
        guard let (data, response) = try? await client.data(from: url) else {
            throw Error.connectivity
        }
        guard let httpResponse = response as? HTTPURLResponse else {
            throw Error.invalidHTTPResponse
        }
        guard httpResponse.statusCode == 200 else {
            throw Error.invalidStatusCode
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        guard let root = try? decoder.decode(Root.self, from: data) else {
            throw Error.decodingError
        }
        
        return root.recipes
    }
}

public struct Root: Codable {
    let recipes: [Recipe]
    
    public init(recipes: [Recipe]) {
        self.recipes = recipes
    }
}


