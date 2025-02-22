//
//  LocalRecipeCacheTests.swift
//  FetchRecipeTests
//
//  Created by Matt Hunt on 2/22/25.
//

import Foundation
import FetchRecipe
import Testing

class RecipeStore {
    var deletedRecipes: [Recipe] = []
    var deletionCallCount = 0
    
    func deleteCachedRecipes() {
        deletionCallCount += 1
    }
}

struct LocalRecipeLoader {
    let store: RecipeStore
    
    func save(_ recipe: Recipe) {
        store.deleteCachedRecipes()
    }
}

struct LocalRecipeCacheTests {
    
    @Test func testCacheInitDoesNotDeleteData() {
        let (_, store) = makeSUT()
        
        #expect(store.deletedRecipes == [])
    }
    
    @Test func testNewSaveRequestsDeletionOfOldCachedRecipes() {
        let (sut, store) = makeSUT()
        let uniqueRecipe = makeUniqueRecipe()
        
        sut.save(uniqueRecipe)
        
        #expect(store.deletionCallCount == 1)
    }
    
    // MARK: Helpers
    
    func makeSUT() -> (LocalRecipeLoader, RecipeStore) {
        let store = RecipeStore()
        let localRecipeLoader = LocalRecipeLoader(store: store)
        return (localRecipeLoader, store)
    }
    
    func makeUniqueRecipe() -> Recipe {
        Recipe(cuisine: "any",
               name: "any",
               photoUrlLarge: nil,
               photoUrlSmall: nil,
               uuid: UUID().uuidString,
               sourceUrl: nil,
               youtubeUrl: nil)
    }
}
