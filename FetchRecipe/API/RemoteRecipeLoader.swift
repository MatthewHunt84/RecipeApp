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
    }
    
    public init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    public func load() async throws -> [Recipe] {
        let dataFromURL: (data: Data, response: URLResponse)
        do {
            dataFromURL = try await client.data(from: url)
        } catch {
            throw Error.connectivity
        }
        guard let httpResponse = dataFromURL.response as? HTTPURLResponse else {
            throw Error.invalidHTTPResponse
        }
        guard httpResponse.statusCode == 200 else {
            throw Error.invalidStatusCode
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let root = try decoder.decode(Root.self, from: dataFromURL.data)
            return root.recipes
        } catch {
            throw Error.invalidData
        }
    }
}

public struct Root: Codable {
    let recipes: [Recipe]
    
    public init(recipes: [Recipe]) {
        self.recipes = recipes
    }
}


