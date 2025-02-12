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
    
    @Test func loadRequestsDataFromURL() async throws {
        let url = try #require(URL(string:"https://test-url.com"))
        let (sut, client) = makeSUT(url: url)
        try await sut.load()
        
        #expect(client.requestedURLs.count == 1)
        #expect(client.requestedURLs.first == url)
    }
    
    @Test func loadTwiceRequestsDataFromURLTwice() async throws {
        let url = try #require(URL(string:"https://test-url.com"))
        let (sut, client) = makeSUT(url: url)
        try await sut.load()
        try await sut.load()
        
        #expect(client.requestedURLs.count == 2)
        #expect(client.requestedURLs == [url, url])
    }
    
    @Test func loadDeliversConnectivityErrorOnClientError() async throws {
        let url = try #require(URL(string: "https://test-url.com"))
        let (sut, client) = makeSUT(url: url)
        
        client.complete(with: NSError(domain: "Test", code: 0))
        
        await #expect(throws: RemoteRecipeLoader.Error.connectivity) {
            try await sut.load()
        }
        #expect(client.capturedErrors.count == 1)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL) -> (sut: RemoteRecipeLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteRecipeLoader(client: client, url: url)
        return (sut, client)
    }
    
    private final class HTTPClientSpy: HTTPClient {
        
        var requestedURLs: [URL] = []
        var capturedErrors: [Error] = []
        
        func data(from url: URL) async throws {
            requestedURLs.append(url)
            if let mostRecentError = capturedErrors.last {
                throw mostRecentError
            }
        }
        
        func complete(with error: Error) {
            capturedErrors.append(error)
        }
    }
}
