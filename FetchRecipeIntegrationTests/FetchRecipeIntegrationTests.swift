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
        
        let recipes = try await sut.retrieveRecipes()

        #expect(recipes.count == 0)
    }

    @Test func insertion_withEmptyCache_shouldAddRecipesToCache() async throws {
        let sutToPerformSave = await makeSUT()
        let sutToPerformLoad = await makeSUT()
        let insertedRecipes = makeLocalRecipes()
        
        try await sutToPerformSave.insertRecipes(insertedRecipes)
        let retrievedRecipes = try await sutToPerformLoad.retrieveRecipes()
        
        #expect(retrievedRecipes.sorted() == insertedRecipes.sorted())
    }
    
    @Test func insertion_withNonEmptyCache_shouldOverrideCachedRecipes() async throws {
        let sutToPerformFirstSave = await makeSUT()
        let sutToPerformLatestSave = await makeSUT()
        let sutToPerformLoad = await makeSUT()
        
        let firstInsertedRecipes = makeLocalRecipes()
        try await sutToPerformFirstSave.insertRecipes(firstInsertedRecipes)
        
        let latestInsertedRecipes = makeLocalRecipes()
        try await sutToPerformLatestSave.insertRecipes(latestInsertedRecipes)
        
        let retrievedRecipes = try await sutToPerformLoad.retrieveRecipes()
        
        #expect(retrievedRecipes.sorted() == latestInsertedRecipes.sorted())
    }
    func makeSUT() async -> SwiftDataStore {
        let container = try! ModelContainer(for: SwiftDataLocalRecipe.self, configurations: ModelConfiguration(isStoredInMemoryOnly: false))
        let sut = SwiftDataStore(modelContainer: container)
        try! await #require(try sut.deleteCachedRecipes())
        
        return sut
    }
}
