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

}
