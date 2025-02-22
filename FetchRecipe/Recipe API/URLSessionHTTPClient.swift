//
//  URLSessionHTTPClient.swift
//  FetchRecipe
//
//  Created by Matt Hunt on 2/21/25.
//
import Foundation

public struct URLSessionHTTPClient: HTTPClient {

    private let session: URLSession
    
    public init() {
        self.session = URLSession.shared
    }
    
    public func data(from url: URL) async throws -> (Data, URLResponse) {
        try await session.data(from: url)
    }
}
