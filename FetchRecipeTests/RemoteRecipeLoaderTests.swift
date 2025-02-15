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
        
        try await sut.load()
        
        #expect(client.messages.count == 1)
        #expect(client.messages.last?.url == url)
    }
    
    @Test func loadTwiceRequestsDataFromURLTwice() async throws {
        let url = try #require(URL(string:"https://test-url.com"))
        let (sut, client) = makeSUT(url: url)
        
        try await sut.load()
        try await sut.load()
        
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
    
    @Test func clientCanCompleteWithData() async throws {
        let (sut, client) = makeSUT()
        let testData = Data("test-data".utf8)
        client.complete(withStatusCode: 200, data: testData)
        
        try await sut.load()
        
        #expect(client.messages.last?.data == testData)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL? = nil) -> (sut: RemoteRecipeLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteRecipeLoader(client: client, url: url ?? makeStubbedURL())
        return (sut, client)
    }
    
    private func makeStubbedURL() -> URL {
        return try! #require(URL(string: "https://test-url.com"))
    }
    
    private final class HTTPClientSpy: HTTPClient {
        
        var messages: [(url: URL?, response: URLResponse?, data: Data?, error: Error?)] = []
        
        func data(from url: URL) async throws -> URLResponse {
            let message = getStubbedMessages(for: url)
            if let error = message.error {
                throw error
            }
    
            return try #require(message.response)
        }
        
        func complete(with error: Error) {
            messages.append((url: nil, response: nil, data: nil, error: error))
        }
        
        func complete(withStatusCode code: Int, data: Data? = nil) {
            let response = stubResponse(withStatusCode: code)
            messages.append((url: nil, response: response, data: data, error: nil))
        }
        
        func getStubbedMessages(for url: URL) -> (url: URL?, response: URLResponse?, data: Data?, error: Error?) {
            if var stubbedMessage = messages.first(where: { $0.url == nil }) {
                stubbedMessage.url = url
                return stubbedMessage
            } else {
                let newMessage: (url: URL?, response: URLResponse?, data: Data?, error: Error?) = (
                    url: url,
                    response: stubResponse(withStatusCode: 200),
                    data: nil,
                    error: nil)
                messages.append(newMessage)
                return newMessage
            }
        }
        
        func stubResponse(withStatusCode code: Int) -> HTTPURLResponse {
            let url = try! #require(URL(string: "https://test-url.com"))
            return try! #require(
                HTTPURLResponse(
                    url: url,
                    statusCode: code,
                    httpVersion: nil,
                    headerFields: nil))
        }
    }
    
}
