//
//  SwiftDataRecipeStore.swift
//  FetchRecipeTests
//
//  Created by Matt Hunt on 2/24/25.
//

import Testing
import Foundation
import FetchRecipe
import SwiftData


@Suite(.serialized)
struct SwiftDataRecipeStore {

    @Test func retrieveRecipes_withEmptyCache_shouldReturnEmptyArray() async throws {
        let sut = try makeSUT()
        
        let emptyRecipes = try await sut.retrieveRecipes()
        
        #expect(emptyRecipes.isEmpty)
    }
    
    @Test func retrieveRecipes_multipleTimesWithEmptyCache_shouldReturnEmptyArrays() async throws {
        let sut = try makeSUT()

        let emptyRecipes = try await sut.retrieveRecipes()
        let emptyRecipes2 = try await sut.retrieveRecipes()
        let emptyRecipes3 = try await sut.retrieveRecipes()
        
        #expect(emptyRecipes.isEmpty)
        #expect(emptyRecipes2.isEmpty)
        #expect(emptyRecipes3.isEmpty)
    }
    
    @Test func retrieveRecipes_withCachedRecipes_shouldReturnCachedRecipes() async throws {
        let sut = try makeSUT()

        let insertedRecipes = makeLocalRecipes()
        
        try await sut.insertRecipes(insertedRecipes)
        let retrievedRecipes = try await sut.retrieveRecipes()
        
        #expect(retrievedRecipes.sorted() == insertedRecipes.sorted())
    }
    
    @Test func retrieveRecipes_multipleTimesWithCachedRecipes_shouldReturnCachedRecipes() async throws {
        let sut = try makeSUT()
        
        let insertedRecipes = makeLocalRecipes()
        
        try await sut.insertRecipes(insertedRecipes)
        let firstRetrievedRecipes = try await sut.retrieveRecipes()
        let secondRetrievedRecipes = try await sut.retrieveRecipes()
        
        #expect(firstRetrievedRecipes.sorted() == secondRetrievedRecipes.sorted())
    }
    
    @Test func insertRecipes_overridesPreviouslyInsertedRecipes() async throws {
        let sut = try makeSUT()
        let firstRecipes = makeLocalRecipes()
        let secondRecipes = makeLocalRecipes()
        
        try await sut.insertRecipes(firstRecipes)
        try await sut.insertRecipes(secondRecipes)
        let storedRecipes = try await sut.retrieveRecipes()
        
        #expect(storedRecipes.sorted() == secondRecipes.sorted())
    }
    
    @Test func insertRecipes_withDuplicateRecipes_shouldNotInsertDuplicates() async throws {
        let sut = try makeSUT()
        let recipesWithDuplicate = makeLocalRecipesWithDuplicates()
        try #require(recipesWithDuplicate.count == 2)
        
        try await sut.insertRecipes(recipesWithDuplicate)
        let retrievedRecipes = try await sut.retrieveRecipes()
        
        #expect(retrievedRecipes.count ==  1)
    }
    
    // MARK: Helpers
    
    func makeSUT() throws -> SwiftDataStore {
        let container = try ModelContainer(for: SwiftDataLocalRecipe.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let sut = SwiftDataStore(modelContainer: container)
        return sut
    }

    func makeLocalRecipesWithDuplicates() -> [LocalRecipe] {
        let originalRecipe = makeLocalRecipe()
        let duplicateRecipe = LocalRecipe(
            cuisine: originalRecipe.cuisine,
            name: originalRecipe.cuisine,
            photoUrlLarge: originalRecipe.photoUrlLarge,
            photoUrlSmall: originalRecipe.photoUrlSmall,
            uuid: originalRecipe.uuid,
            sourceUrl: originalRecipe.sourceUrl,
            youtubeUrl: originalRecipe.youtubeUrl)
        
        return [originalRecipe, duplicateRecipe]
    }
    
    func makeLocalRecipe() -> LocalRecipe {
        LocalRecipe(
            cuisine: "Any",
            name: "Any",
            photoUrlLarge: nil,
            photoUrlSmall: nil,
            uuid: UUID().uuidString,
            sourceUrl: nil,
            youtubeUrl: nil)
    }

    func makeLocalRecipes() -> [LocalRecipe] {
        (0..<Int.random(in: 1...10)).map { _ in makeLocalRecipe() }
    }
}
