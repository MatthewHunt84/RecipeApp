//
//  FetchRecipeCacheIntegrationTests.swift
//  FetchRecipeCacheIntegrationTests
//
//  Created by Matt Hunt on 3/5/25.
//

import Testing
import FetchRecipe
import Foundation
import SwiftData

@Suite(.serialized)
struct FetchRecipeCacheIntegrationTests {

    @Test func load_withEmptyCache_shouldReturnEmptyRecipeArray() async throws {
        let recipeLoader = try await makeLocalRecipeLoader()
        
        let recipes = try await recipeLoader.load()

        #expect(recipes.count == 0)
    }

    @Test func save_withEmptyCache_shouldAddRecipesToCache() async throws {
        let recipeLoaderToPerformSave = try await makeLocalRecipeLoader()
        let recipeLoaderToPerformLoad = try await makeLocalRecipeLoader()
        let insertedRecipes = makeRecipes()
        
        try await recipeLoaderToPerformSave.save(insertedRecipes)
        let retrievedRecipes = try await recipeLoaderToPerformLoad.load()
        
        #expect(retrievedRecipes.sorted() == insertedRecipes.sorted())
    }
    
    @Test func save_withNonEmptyCache_shouldOverrideCachedRecipes() async throws {
        let recipeLoaderToPerformFirstSave = try await makeLocalRecipeLoader()
        let recipeLoaderToPerformLatestSave = try await makeLocalRecipeLoader()
        let recipeLoaderToPerformLoad = try await makeLocalRecipeLoader()
        
        let firstInsertedRecipes = makeRecipes()
        try await recipeLoaderToPerformFirstSave.save(firstInsertedRecipes)
        
        let latestInsertedRecipes = makeRecipes()
        try await recipeLoaderToPerformLatestSave.save(latestInsertedRecipes)
        let retrievedRecipes = try await recipeLoaderToPerformLoad.load()
        
        #expect(retrievedRecipes.sorted() == latestInsertedRecipes.sorted())
    }
    
    @Test func imageLoader_withSeparateRecipeLoaderInstance_shouldAccessSameDataStore() async throws {
        let recipeLoader = try await makeLocalRecipeLoader()
        let imageLoader = try await makeLocalRecipeImageLoader()
        let url = try makeUrl()
        let recipe = makeRecipe(for: url.urlString)
        let data = try mockUniqueImageData()
        
        try await recipeLoader.save([recipe])
        try await imageLoader.save(data, for: url.url)
        let result = try await imageLoader.loadImageData(for: url.url)
        
        #expect(result == data)
    }
    
    @Test func RecipeLoader_withSeparateImageLoaderInstance_shouldOverwriteCachedImageData() async throws {
        let recipeLoader = try await makeLocalRecipeLoader()
        let imageLoader = try await makeLocalRecipeImageLoader()
        let url = try makeUrl()
        let recipe = makeRecipe(for: url.urlString)
        let data = try mockUniqueImageData()
        
        try await recipeLoader.save([recipe])
        try await imageLoader.save(data, for: url.url)
        try await recipeLoader.save([recipe])
        
        await #expect(throws: LocalRecipeImageDataLoader.Error.failedToLoad) {
            let _ = try await imageLoader.loadImageData(for: url.url)
        }
    }
    
    // MARK: Helpers

    private func makeLocalRecipeLoader() async throws -> LocalRecipeLoader {
        let container = try ModelContainer(for: SwiftDataLocalRecipe.self, configurations: ModelConfiguration(isStoredInMemoryOnly: false))
        let swiftDataStore = SwiftDataStore(modelContainer: container)
        try await swiftDataStore.deleteCachedRecipes()
        let recipeLoader = LocalRecipeLoader(store: swiftDataStore)
        
        return recipeLoader
    }
    
    private func makeLocalRecipeImageLoader() async throws -> LocalRecipeImageDataLoader {
        let container = try ModelContainer(for: SwiftDataLocalRecipe.self, configurations: ModelConfiguration(isStoredInMemoryOnly: false))
        let swiftDataStore = SwiftDataStore(modelContainer: container)
        
        let imageDataLoader = LocalRecipeImageDataLoader(store: swiftDataStore)
        return imageDataLoader
    }
    
    private func makeRecipe() -> Recipe {
        Recipe(
            cuisine: "Any",
            name: "Any",
            photoUrlLarge: nil,
            photoUrlSmall: nil,
            id: UUID().uuidString,
            sourceUrl: nil,
            youtubeUrl: nil,
            photoUrlSmallImageData: nil)
    }
    
    private func makeRecipe(for url: String?) -> Recipe {
        Recipe(
            cuisine: "Any",
            name: "Any",
            photoUrlLarge: nil,
            photoUrlSmall: url,
            id: UUID().uuidString,
            sourceUrl: nil,
            youtubeUrl: nil,
            photoUrlSmallImageData: nil)
    }

    private func makeRecipes() -> [Recipe] {
        (0..<Int.random(in: 1...10)).map { _ in makeRecipe() }
    }
    
    private func makeUrl() throws -> (url: URL, urlString: String) {
            let uniqueURL = "https://imageData-url-\(UUID().uuidString).com"
            let url = try #require(URL(string: uniqueURL))
            return (url, uniqueURL)
    }
    
    private func mockUniqueImageData() throws -> Data {
        try #require(UUID().uuidString.data(using: .utf8))
    }
}
