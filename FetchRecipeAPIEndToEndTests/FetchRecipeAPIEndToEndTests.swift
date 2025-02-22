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
        
        let expectedFirstRecipe = Recipe(
            cuisine: "Malaysian",
            name: "Apam Balik",
            photoUrlLarge: Optional("https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/large.jpg"),
            photoUrlSmall: Optional("https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/small.jpg"),
            uuid: "0c6ca6e7-e32a-4053-b824-1dbf749910d8",
            sourceUrl: Optional("https://www.nyonyacooking.com/recipes/apam-balik~SJ5WuvsDf9WQ"),
            youtubeUrl: Optional("https://www.youtube.com/watch?v=6R8ffRRJcrg"))
        
        let expectedSecondRecipe = Recipe(
            cuisine: "British",
            name: "Apple & Blackberry Crumble",
            photoUrlLarge: Optional("https://d3jbb8n5wk0qxi.cloudfront.net/photos/535dfe4e-5d61-4db6-ba8f-7a27b1214f5d/large.jpg"),
            photoUrlSmall: Optional("https://d3jbb8n5wk0qxi.cloudfront.net/photos/535dfe4e-5d61-4db6-ba8f-7a27b1214f5d/small.jpg"),
            uuid: "599344f4-3c5c-4cca-b914-2210e3b3312f",
            sourceUrl: Optional("https://www.bbcgoodfood.com/recipes/778642/apple-and-blackberry-crumble"),
            youtubeUrl: Optional("https://www.youtube.com/watch?v=4vhcOwVBDO4"))
        
        #expect(recipes.first == expectedFirstRecipe)
        #expect(recipes[1] == expectedSecondRecipe)
    }

}
