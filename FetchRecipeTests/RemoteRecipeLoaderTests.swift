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

        #expect(client.requestedURLs.isEmpty)
    }
    
    @Test func loadRequestsDataFromURL() throws {
        let url = try #require(URL(string:"https://test-url.com"))
        let (sut, client) = makeSUT(url: url)
        sut.load()
        
        #expect(client.requestedURLs.count == 1)
        #expect(client.requestedURLs.first == url)
    }
    
    @Test func loadTwiceRequestsDataFromURLTwice() throws {
        let url = try #require(URL(string:"https://test-url.com"))
        let (sut, client) = makeSUT(url: url)
        sut.load()
        sut.load()
        
        #expect(client.requestedURLs.count == 2)
        #expect(client.requestedURLs == [url, url])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL) -> (sut: RemoteRecipeLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteRecipeLoader(client: client, url: url)
        return (sut, client)
    }
    
    private final class HTTPClientSpy: HTTPClient {
        
        var requestedURLs: [URL] = []
        
        func data(from url: URL) {
            requestedURLs.append(url)
        }
    }
}
