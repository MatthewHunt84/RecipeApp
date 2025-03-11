//
//  FetchRecipeTests.swift
//  FetchRecipeTests
//
//  Created by Matt Hunt on 2/9/25.
//

import Testing
import Foundation
import FetchRecipe

struct RemoteRecipeLoaderTests {
    
    @Test func init_shouldNotRequestData() throws {
        let (_, client) = try makeSUT()
        
        #expect(client.stubs.isEmpty)
    }
    
    @Test func load_shouldRequestDataFromUrl() async throws {
        let url = try #require(URL(string:"https://test-specific-url.com"))
        let (sut, client) = try makeSUT(url: url)
        let result = try makeResult()
        client.stub(url: url, with: result)
        
        let _ = try await sut.load()
        
        #expect(client.completedRequests.count == 1)
        #expect(client.completedRequests.last?.url == url)
    }
    
    @Test func load_twice_shouldRequestsDataFromURLTwice() async throws {
        let url = try #require(URL(string:"https://test-url.com"))
        let (sut, client) = try makeSUT(url: url)
        let result = try makeResult()
        client.stub(url: url, with: result)
        client.stub(url: url, with: result)
        
        let _ = try await sut.load()
        let _ = try await sut.load()
        
        #expect(client.completedRequests.count == 2)
        #expect(client.completedRequests[0].url == url)
        #expect(client.completedRequests[1].url == url)
    }
    
    @Test func load_withConnectivityError_throwsClientError() async throws {
        let (sut, client) = try makeSUT()
        let url = try makeStubbedURL()
        let result = try makeResult(error: NSError(domain: "Test", code: 0))
        client.stub(url: url, with: result)
        
        await #expect(throws: RemoteRecipeLoader.Error.connectivity) {
            try await sut.load()
        }
    }
    
    @Test(arguments: [199, 201, 300, 400, 500])
    func load_withNon200HTTPResponse_shouldThrowError(statusCode: Int) async throws {
        let (sut, client) = try makeSUT()
        let url = try makeStubbedURL()
        let result = try makeResult(responseStatusCode: statusCode)
        client.stub(url: url, with: result)
        
        await #expect(throws: RemoteRecipeLoader.Error.invalidStatusCode) {
            try await sut.load()
        }
    }
    
    @Test func load_withEmptyData_shouldReturnEmptyRecipeArray() async throws {
        let (sut, client) = try makeSUT()
        let url = try makeStubbedURL()
        let result = try makeResult(data: stubEmptyData())
        client.stub(url: url, with: result)
        
        let recipes = try await sut.load()
        
        #expect(recipes == [])
    }
    
    @Test func load_withValidData_shouldReturnRecipeArray() async throws {
        let (sut, client) = try makeSUT()
        let url = try makeStubbedURL()
        
        let bakeWellTart = makeRecipe(name: "Bakewell Tart")
        let figgyPudding = makeRecipe(name: "Figgy Pudding")
        let recipesJSONData = try makeRecipeJSON(from: [bakeWellTart.json, figgyPudding.json])

        let result = try makeResult(data: recipesJSONData)
        client.stub(url: url, with: result)
        
        let loadedRecipes = try await sut.load()
        
        #expect(loadedRecipes == [bakeWellTart.recipe, figgyPudding.recipe])
    }
    
    @Test func load_withInvalidData_shouldThrowDecodingError() async throws {
        let (sut, client) = try makeSUT()
        let url = try makeStubbedURL()

        let result = try makeResult(data: Data("invalid-data".utf8))
        client.stub(url: url, with: result)
        
        await #expect(throws: RemoteRecipeLoader.Error.decodingError) {
            let _ = try await sut.load()
        }
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL? = nil) throws -> (sut: RemoteRecipeLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        guard let url else {
            let stubbedURL = try makeStubbedURL()
            let sut = RemoteRecipeLoader(client: client, url: stubbedURL)
            return (sut, client)
        }
        let sut = RemoteRecipeLoader(client: client, url: url)
        return (sut, client)
    }
    
    private func makeStubbedURL() throws -> URL {
        return try #require(URL(string: "https://default-test-url.com"))
    }
    
    private func stubResponse(code: Int) throws -> HTTPURLResponse {
        let url = try #require(URL(string: "https://test-url.com"))
        return try #require(HTTPURLResponse(url: url, statusCode: code, httpVersion: nil, headerFields: nil))
    }
    
    private func makeResult(error: Error? = nil, responseStatusCode: Int = 200, data: Data? = nil) throws -> Result<(Data, URLResponse), Error> {
        if let error {
            return .failure(error)
        }
        let response = try #require(try stubResponse(code: responseStatusCode))
        
        if let data {
            return .success((data, response))
        } else {
            let validData = try stubEmptyData()
            return .success((validData, response))
        }
    }
    
    private func stubEmptyData() throws -> Data {
        try #require("""
        {
            "recipes": []
        }
        """.data(using: .utf8))
    }
    
    private func makeRecipe(
        cuisine: String = "Cuisine",
        name: String = "Name",
        photoUrlLarge: String? = "https://some.url/large.jpg",
        photoUrlSmall: String? = "https://some.url/small.jpg",
        uuid: String = "eed6005f-f8c8-451f-98d0-4088e2b40eb6",
        sourceUrl: String? = "https://some.url/index.html",
        youtubeUrl: String? = "https://www.youtube.com/watch?v=some.id") -> (recipe: Recipe, json: [String: Any]) {
       
        let json: [String: Any] = [
            "cuisine": cuisine,
            "name": name,
            "photo_url_large": photoUrlLarge,
            "photo_url_small": photoUrlSmall,
            "uuid": uuid,
            "source_url": sourceUrl,
            "youtube_url": youtubeUrl
        ].compactMapValues { $0 }
        
        let recipe = Recipe(cuisine: cuisine,
                            name: name,
                            photoUrlLarge: photoUrlLarge,
                            photoUrlSmall: photoUrlSmall,
                            uuid: uuid,
                            sourceUrl: sourceUrl,
                            youtubeUrl: youtubeUrl)
        
        return (recipe: recipe, json: json)
    }
    
    private func makeRecipeJSON(from json: [[String: Any]]) throws -> Data {
        let recipesJSON = [
            "recipes" : json
        ]
        return try JSONSerialization.data(withJSONObject: recipesJSON)
    }
    
    private final class HTTPClientSpy: HTTPClient {
        
        var stubs: [(url: URL, result: Result<(Data, URLResponse), Error>)] = []
        var completedRequests: [(url: URL, result: Result<(Data, URLResponse), Error>)] = []
        
        func stub(url: URL, with result: Result<(Data, URLResponse), Error>) {
            stubs.append((url: url, result: result))
        }
        
        func data(from url: URL) async throws -> (Data, URLResponse) {
            let matchedStubIndex = try #require(stubs.firstIndex(where: { $0.url == url }))
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
