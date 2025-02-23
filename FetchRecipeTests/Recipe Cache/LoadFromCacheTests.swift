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

    @Test func testCacheInitDoesNotLoadOrDeleteRecipes() {
        let (_, store) = makeSUT()
        
        #expect(store.savedRecipes == [])
        #expect(store.deletedRecipes == [])
    }
    
    @Test func testLoadFromCacheRetrievesSavedRecipes() throws {
        let (sut, _) = makeSUT()
        
        let emptyRecipes = try sut.load()
        
        #expect(emptyRecipes == [])
    }
    
    @Test func testLoadFailsOnRetrievalError() throws {
        let (sut, store) = makeSUT()
        let retrievalError = NSError(domain: "Cache Retrieval Error", code: 0)
        store.stubRetrievalResult(.failure(retrievalError))
        
        #expect(throws: retrievalError) {
            let _ = try sut.load()
        }
    }
    
    @Test func testLoadDeliversNoRecipesFromEmptyCache() throws {
        let (sut, store) = makeSUT()
        try #require(store.savedRecipes.isEmpty)
        
        let recipes = try sut.load()
        
        #expect(recipes.isEmpty)
        
    }
    
    func makeSUT() -> (LocalRecipeLoader, RecipeStoreSpy) {
        let store = RecipeStoreSpy()
        let localRecipeLoader = LocalRecipeLoader(store: store)
        return (localRecipeLoader, store)
    }
}
