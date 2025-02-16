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
    
    @Test func loadDeliversRecipesFromValidData() async throws {
        let (sut, client) = makeSUT()
        let url = makeStubbedURL()
        
        let bakeWellTart = makeRecipe(name: "Bakewell Tart")
        let figgyPudding = makeRecipe(name: "Figgy Pudding")
        let recipesJSONData = makeRecipeJSON(from: [bakeWellTart.json, figgyPudding.json])

        let result = makeResult(data: recipesJSONData)
        client.stub(url: url, with: result)
        
        let loadedRecipes = try await sut.load()
        
        #expect(loadedRecipes == [bakeWellTart.recipe, figgyPudding.recipe])
    }
    
    @Test func invalidDataThrowsDecodingError() async throws {
        let (sut, client) = makeSUT()
        let url = makeStubbedURL()

        let result = makeResult(data: Data("invalid-data".utf8))
        client.stub(url: url, with: result)
        
        await #expect(throws: RemoteRecipeLoader.Error.decodingError) {
            let loadedRecipes = try await sut.load()
        }
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
    
    private func stubEmptyData() -> Data {
        let emptyRecipeData = Root(recipes: [])
        let data = try! #require(try JSONEncoder().encode(emptyRecipeData))
        return data
    }
    
    private func makeRecipe(cuisine: String = "Cuisine",
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
    
    private func makeRecipeJSON(from json: [[String: Any]]) -> Data {
        let recipesJSON = [
            "recipes" : json
        ]
        return try! #require(try JSONSerialization.data(withJSONObject: recipesJSON))
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
