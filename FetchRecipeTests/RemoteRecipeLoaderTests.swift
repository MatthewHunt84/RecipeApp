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

        #expect(client.stubs.isEmpty)
    }
    
    @Test func loadRequestsDataFromURL() async throws {
        let url = try #require(URL(string:"https://test-specific-url.com"))
        let (sut, client) = makeSUT(url: url)
        let result = makeResult()
        client.stub(url: url, with: result)
        
        let _ = try await sut.load()
        
        #expect(client.completedRequests.count == 1)
        #expect(client.completedRequests.last?.url == url)
    }
    
    @Test func loadTwiceRequestsDataFromURLTwice() async throws {
        let url = try #require(URL(string:"https://test-url.com"))
        let (sut, client) = makeSUT(url: url)
        let result = makeResult()
        client.stub(url: url, with: result)
        client.stub(url: url, with: result)
        
        let _ = try await sut.load()
        let _ = try await sut.load()
        
        #expect(client.completedRequests.count == 2)
        #expect(client.completedRequests[0].url == url)
        #expect(client.completedRequests[1].url == url)
    }
    
    @Test func loadDeliversConnectivityErrorOnClientError() async throws {
        let (sut, client) = makeSUT()
        let url = makeStubbedURL()
        let result = makeResult(error: NSError(domain: "Test", code: 0))
        client.stub(url: url, with: result)
        
        await #expect(throws: RemoteRecipeLoader.Error.connectivity) {
            try await sut.load()
        }
    }
    
    @Test(arguments: [199, 201, 300, 400, 500])
    func loadDeliversErrorOnNon200HTTPResponse(statusCode: Int) async throws {
        let (sut, client) = makeSUT()
        let url = makeStubbedURL()
        let result = makeResult(responseStatusCode: statusCode)
        client.stub(url: url, with: result)
        
        await #expect(throws: RemoteRecipeLoader.Error.invalidStatusCode) {
            try await sut.load()
        }
    }
    
    @Test func clientCanCompleteWithEmptyData() async throws {
        let (sut, client) = makeSUT()
        let url = makeStubbedURL()
        let result = makeResult(data: stubEmptyData())
        client.stub(url: url, with: result)
        
        let recipes = try await sut.load()
        
        #expect(recipes == [])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL? = nil) -> (sut: RemoteRecipeLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteRecipeLoader(client: client, url: url ?? makeStubbedURL())
        return (sut, client)
    }
    
    private func makeStubbedURL() -> URL {
        return try! #require(URL(string: "https://default-test-url.com"))
    }
    
    private func stubResponse(code: Int) -> HTTPURLResponse {
        let url = try! #require(URL(string: "https://test-url.com"))
        return try! #require(
            HTTPURLResponse(
                url: url,
                statusCode: code,
                httpVersion: nil,
                headerFields: nil))
    }
    
    private func makeResult(error: Error? = nil, responseStatusCode: Int = 200, data: Data? = nil) -> Result<(Data, URLResponse), Error> {
        if let error {
            return .failure(error)
        }
        let response = stubResponse(code: responseStatusCode)
        let validData = data ?? stubEmptyData()
        
        return .success((validData, response))
    }
    
    func stubEmptyData() -> Data {
        let emptyRecipeData = Root(recipes: [])
        let data = try! JSONEncoder().encode(emptyRecipeData)
        return data
    }
    
    private final class HTTPClientSpy: HTTPClient {
        
        var stubs: [(url: URL, result: Result<(Data, URLResponse), Error>)] = []
        var completedRequests: [(url: URL, result: Result<(Data, URLResponse), Error>)] = []
        
        func stub(url: URL, with result: Result<(Data, URLResponse), Error>) {
            stubs.append((url: url, result: result))
        }
        
        func data(from url: URL) async throws -> (Data, URLResponse) {
            let matchedStubIndex = try! #require(stubs.firstIndex(where: { $0.url == url }))
            let matchedStub = stubs.remove(at: matchedStubIndex)
            completedRequests.append(matchedStub)
            
            switch matchedStub.result {
            case .success(let result):
                return result
            case .failure(let error):
                throw error
            }
        }
    }
}
