//
//  Untitled.swift
//  FetchRecipe
//
//  Created by Matt Hunt on 2/10/25.
//

import Foundation



public struct RemoteRecipeLoader {
    
    private let client: HTTPClient
    private let url: URL
    
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
        
        return try RecipeMapper.map(data, response)
    }
}

public struct Root: Codable {
    let recipes: [Recipe]
    
    public init(recipes: [Recipe]) {
        self.recipes = recipes
    }
}




