//
//  LoadFromCacheTests.swift
//  FetchRecipeTests
//
//  Created by Matt Hunt on 2/23/25.
//

import FetchRecipe
import Testing

struct LoadFromCacheTests {

    @Test func testCacheInitDoesNotLoadOrDeleteRecipes() async throws {
        let (_, store) = makeSUT()
        
        #expect(store.savedRecipes == [])
        #expect(store.deletedRecipes == [])
    }
    
    @Test func testLoadFromCacheRetrievesSavedRecipes() async throws {
        let (sut, _) = makeSUT()
        
        let emptyRecipes = try sut.load()
        
        #expect(emptyRecipes == [])
    }
    
    func makeSUT() -> (LocalRecipeLoader, RecipeStoreSpy) {
        let store = RecipeStoreSpy()
        let localRecipeLoader = LocalRecipeLoader(store: store)
        return (localRecipeLoader, store)
    }
}
