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
        let (_, client) = makeSUT()

        #expect(client.messages.isEmpty)
    }
    
    @Test func loadRequestsDataFromURL() async throws {
        let url = try #require(URL(string:"https://test-specific-url.com"))
        let (sut, client) = makeSUT(url: url)
        
        await #expect(throws: RemoteRecipeLoader.Error.connectivity) {
            try await sut.load()
        }
        
        #expect(client.messages.count == 1)
        #expect(client.messages.last?.url == url)
    }
    
    @Test func loadTwiceRequestsDataFromURLTwice() async throws {
        let url = try #require(URL(string:"https://test-url.com"))
        let (sut, client) = makeSUT(url: url)
        await #expect(throws: RemoteRecipeLoader.Error.connectivity) {
            try await sut.load()
        }
        await #expect(throws: RemoteRecipeLoader.Error.connectivity) {
            try await sut.load()
        }
        
        #expect(client.messages.count == 2)
        #expect(client.messages.first?.url == url)
        #expect(client.messages.last?.url == url)
    }
    
    @Test func loadDeliversConnectivityErrorOnClientError() async throws {
        let (sut, client) = makeSUT()
        
        client.complete(with: NSError(domain: "Test", code: 0))
        
        await #expect(throws: RemoteRecipeLoader.Error.connectivity) {
            try await sut.load()
        }
        #expect(client.messages.count == 1)
    }
    
    @Test(arguments: [199, 201, 300, 400, 500])
    func loadDeliversErrorOnNon200HTTPResponse(statusCode: Int) async throws {
        
        let (sut, client) = makeSUT()
        
        client.complete(withStatusCode: statusCode)
        
        await #expect(throws: RemoteRecipeLoader.Error.invalidStatusCode) {
            try await sut.load()
        }
        #expect(client.messages.count == 1)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL? = nil) -> (sut: RemoteRecipeLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteRecipeLoader(client: client, url: url ?? getStubbedURL())
        return (sut, client)
    }
    
    private func getStubbedURL() -> URL {
        return try! #require(URL(string: "https://test-url.com"))
    }
    
    private final class HTTPClientSpy: HTTPClient {
        
        var messages: [(url: URL?, response: URLResponse?, error: Error?)] = []
        
        func data(from url: URL) async throws -> URLResponse? {
            let message = getStubbedMessages(for: url)
            guard message.error == nil else {
                throw message.error!
            }
            if let response = message.response {
                return response
            }
            return nil
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages.append((url: nil, response: nil, error: error))
        }
        
        func complete(withStatusCode code: Int, at index: Int = 0) {
            let response = HTTPURLResponse(
                url: URL(string: "https://test-url.com")!,
                statusCode: code,
                httpVersion: nil,
                headerFields: nil)
            messages.append((url: nil, response: response, error: nil))
        }
        
        func getStubbedMessages(for url: URL) -> (url: URL?, response: URLResponse?, error: Error?) {
            if var stubbedMessage = messages.first(where: { $0.url == nil }) {
                stubbedMessage.url = url
                return stubbedMessage
            } else {
                let newMessage: (url: URL?, response: URLResponse?, error: Error?) = (url: url, response: nil, error: nil)
                messages.append(newMessage)
                return newMessage
            }
        }
    }
    
}
