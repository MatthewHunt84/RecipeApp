//
//  SaveToCacheTests.swift
//  FetchRecipeTests
//
//  Created by Matt Hunt on 2/22/25.
//

import Foundation
import FetchRecipe
import Testing

struct SaveToCacheTests {
    
    @Test func save_withCachedRecipes_shouldDeletePreviouslyCachedRecipes() async throws {
        let (sut, store) = makeSUT()
        let recipe1 = [makeUniqueRecipe()]
        let recipe2 = [makeUniqueRecipe()]
        
        try await sut.save(recipe1)
        try await sut.save(recipe2)
        
        #expect(store.deletedRecipes.count == 1)
    }
    
    @Test func save_withDeletionError_shouldNotSaveRecipesToCache() async throws {
        let (sut, store) = makeSUT()
        let recipes = makeUniqueRecipes()
        let deletionError = NSError(domain: "Deletion Error", code: 0)
        
        store.stubDeletionResult(.failure(deletionError))
        
        await #expect(throws: deletionError) {
            try await sut.save(recipes.models)
        }
        
        #expect(store.savedRecipes.count == 0)
    }

    @Test func save_withSuccessfulCacheDeletion_shouldSaveLatestRecipes() async throws {
        let (sut, store) = makeSUT()
        let recipes = makeUniqueRecipes()
        
        try await sut.save(recipes.models)
        
        #expect(store.savedRecipes == recipes.local)
    }

    @Test func save_withSaveError_shouldNotSaveRecipes() async throws {
        let (sut, store) = makeSUT()
        let recipes = makeUniqueRecipes()
        let saveError = NSError(domain: "Save Error", code: 0)
        
        store.stubInsertionResult(.failure(saveError))
        
        await #expect(throws: saveError) {
            try await sut.save(recipes.models)
        }
        
        #expect(store.savedRecipes.isEmpty)
    }
}




