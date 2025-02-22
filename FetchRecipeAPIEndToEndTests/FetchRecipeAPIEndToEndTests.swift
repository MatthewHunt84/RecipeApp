//
//  FetchRecipeAPIEndToEndTests.swift
//  FetchRecipeAPIEndToEndTests
//
//  Created by Matt Hunt on 2/21/25.
//

import Testing
import FetchRecipe
import Foundation

struct FetchRecipeAPIEndToEndTests {

    @Test(.timeLimit(.minutes(1))) func testEndToEndServerGETRecipeDataReturnsData() async throws {
        let client = URLSessionHTTPClient()
        let url = try #require(URL(string:"https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json"))
        let loader = RemoteRecipeLoader(client: client, url: url)
        
        let recipes = try await loader.load()
        
        #expect(recipes != nil)
        #expect(recipes.count == 63)
    }
    
    @Test func testEndToEndServerGETRecipeDataMatchesExpectedRecipes() async throws {
        let client = URLSessionHTTPClient()
        let url = try #require(URL(string:"https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json"))
        let loader = RemoteRecipeLoader(client: client, url: url)
        
        let recipes = try await loader.load()
        
        #expect(recipes[0] == expectedRecipe(at: 0))
        #expect(recipes[1] == expectedRecipe(at: 1))
    }
    
    
    // MARK: Helpers
    
    func expectedRecipe(at index: Int) -> Recipe {
        Recipe(cuisine: cuisine(at: index),
               name: name(at: index),
               photoUrlLarge: photoURLLarge(at: index),
               photoUrlSmall: photoURLSmall(at: index),
               uuid: uuid(at: index),
               sourceUrl: sourceURL(at: index),
               youtubeUrl: youtubeURL(at: index))
    }
    
    func cuisine(at index: Int) -> String {
        let cuisines = ["Malaysian", "British"]
        return cuisines[index]
    }
    
    func name(at index: Int) -> String {
        let names = ["Apam Balik", "Apple & Blackberry Crumble"]
        return names[index]
    }
    
    func photoURLLarge(at index: Int) -> String? {
        let photos = ["https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/large.jpg", "https://d3jbb8n5wk0qxi.cloudfront.net/photos/535dfe4e-5d61-4db6-ba8f-7a27b1214f5d/large.jpg"]
        return photos[index]
    }
    
    func photoURLSmall(at index: Int) -> String? {
        let photos = ["https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/small.jpg", "https://d3jbb8n5wk0qxi.cloudfront.net/photos/535dfe4e-5d61-4db6-ba8f-7a27b1214f5d/small.jpg"]
        return photos[index]
    }
    
    func uuid(at index: Int) -> String {
        let uuids = ["0c6ca6e7-e32a-4053-b824-1dbf749910d8", "599344f4-3c5c-4cca-b914-2210e3b3312f"]
        return uuids[index]
    }
    
    func sourceURL(at index: Int) -> String? {
        let sourceURLs = ["https://www.nyonyacooking.com/recipes/apam-balik~SJ5WuvsDf9WQ", "https://www.bbcgoodfood.com/recipes/778642/apple-and-blackberry-crumble"]
        return sourceURLs[index]
    }
    
    func youtubeURL(at index: Int) -> String? {
        let youtubeURLs = ["https://www.youtube.com/watch?v=6R8ffRRJcrg", "https://www.youtube.com/watch?v=4vhcOwVBDO4"]
        return youtubeURLs[index]
    }

}
