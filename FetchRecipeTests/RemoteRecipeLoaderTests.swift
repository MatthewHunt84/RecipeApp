//
//  FetchRecipeTests.swift
//  FetchRecipeTests
//
//  Created by Matt Hunt on 2/9/25.
//

import Testing
import Foundation
import FetchRecipe

struct FetchRecipeTests {

    @Test func initDoesNotRequestData() throws {
        let url = try #require(URL(string:"https://test-url.com"))
        let (_, client) = makeSUT(url: url)

        #expect(client.requestedURL == nil)
    }
    
    @Test func loadRequestsDataFromURL() throws {
        let url = try #require(URL(string:"https://test-url.com"))
        let (sut, client) = makeSUT(url: url)
        sut.load()
        
        #expect(client.requestedURL == url)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL) -> (sut: RemoteRecipeLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteRecipeLoader(client: client, url: url)
        return (sut, client)
    }
    
    private final class HTTPClientSpy: HTTPClient {
        
        var requestedURL: URL?
        
        func data(from url: URL) {
            requestedURL = url
        }
    }
}
