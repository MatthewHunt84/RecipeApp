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
        case invalidStatusCode
        case invalidHTTPResponse
    }
    
    public init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    public func load() async throws {
        let response: URLResponse
        do {
            guard let urlResponse = try await client.data(from: url) else {
                throw Error.connectivity
            }
            response = urlResponse
        } catch {
            throw Error.connectivity
        }
        guard let httpResponse = response as? HTTPURLResponse else {
            throw Error.invalidHTTPResponse
        }
        guard httpResponse.statusCode == 200 else {
            throw Error.invalidStatusCode
        }
    }
}

public protocol HTTPClient {
    func data(from url: URL) async throws -> URLResponse?
}
