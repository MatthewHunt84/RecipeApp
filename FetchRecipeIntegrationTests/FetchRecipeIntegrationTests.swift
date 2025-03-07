//
//  FetchRecipeIntegrationTests.swift
//  FetchRecipeIntegrationTests
//
//  Created by Matt Hunt on 3/5/25.
//

import Testing
import FetchRecipe
import Foundation
import SwiftData

@Suite(.serialized)
struct FetchRecipeIntegrationTests {

    @Test func retrieve_withEmptyCache_shouldReturnEmptyRecipeArray() async throws {
        let sut = await makeSUT()
        
        let recipes = try await sut.load()

        #expect(recipes.count == 0)
    }

    @Test func insertion_withEmptyCache_shouldAddRecipesToCache() async throws {
        let sutToPerformSave = await makeSUT()
        let sutToPerformLoad = await makeSUT()
        let insertedRecipes = makeRecipes()
        
        try await sutToPerformSave.save(insertedRecipes)
        let retrievedRecipes = try await sutToPerformLoad.load()
        
        #expect(retrievedRecipes.sorted() == insertedRecipes.sorted())
    }
    
    @Test func insertion_withNonEmptyCache_shouldOverrideCachedRecipes() async throws {
        let sutToPerformFirstSave = await makeSUT()
        let sutToPerformLatestSave = await makeSUT()
        let sutToPerformLoad = await makeSUT()
        
        let firstInsertedRecipes = makeRecipes()
        try await sutToPerformFirstSave.save(firstInsertedRecipes)
        
        let latestInsertedRecipes = makeRecipes()
        try await sutToPerformLatestSave.save(latestInsertedRecipes)
        let retrievedRecipes = try await sutToPerformLoad.load()
        
        #expect(retrievedRecipes.sorted() == latestInsertedRecipes.sorted())
    }
    
    func makeSUT() async -> LocalRecipeLoader {
        let container = try! ModelContainer(for: SwiftDataLocalRecipe.self, configurations: ModelConfiguration(isStoredInMemoryOnly: false))
        let swiftDataStore = SwiftDataStore(modelContainer: container)
        try! await #require(try swiftDataStore.deleteCachedRecipes())
        let sut = LocalRecipeLoader(store: swiftDataStore)
        
        return sut
    }
    
    func makeRecipe() -> Recipe {
        Recipe(
            cuisine: "Any",
            name: "Any",
            photoUrlLarge: nil,
            photoUrlSmall: nil,
            uuid: UUID().uuidString,
            sourceUrl: nil,
            youtubeUrl: nil)
    }

    func makeRecipes() -> [Recipe] {
        (0..<Int.random(in: 1...10)).map { _ in makeRecipe() }
    }
}
