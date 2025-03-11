//
//  LoadFromCacheTests.swift
//  FetchRecipeTests
//
//  Created by Matt Hunt on 2/23/25.
//

import FetchRecipe
import Testing
import Foundation

struct LoadFromCacheTests {

    @Test func init_withNewCache_shouldNotLoadOrDeleteRecipes() {
        let (_, store) = makeSUT()
        
        #expect(store.savedRecipes == [])
        #expect(store.deletedRecipes == [])
    }
    
    @Test func load_withRetrievalError_shouldThrowError() async throws {
        let (sut, store) = makeSUT()
        let retrievalError = NSError(domain: "Cache Retrieval Error", code: 0)
        store.stubRetrievalResult(.failure(retrievalError))
        
        await #expect(throws: retrievalError) {
            let _ = try await sut.load()
        }
    }
    
    @Test func load_withEmptyCache_shouldReturnEmptyRecipeArray() async throws {
        let (sut, store) = makeSUT()
        try #require(store.savedRecipes.isEmpty)
        
        let recipes = try await sut.load()
        
        #expect(recipes.isEmpty)
    }
    
    @Test func load_withCachedRecipes_shouldReturnCachedRecipes() async throws {
        let (sut, store) = makeSUT()
        let savedRecipes = makeUniqueRecipes()
        store.stubRetrievalResult(.success(savedRecipes.local))
        
        let recipes = try await sut.load()
        
        #expect(recipes == savedRecipes.models)
    }
}
