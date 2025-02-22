//
//  LocalRecipeCacheTests.swift
//  FetchRecipeTests
//
//  Created by Matt Hunt on 2/22/25.
//

import Foundation
import FetchRecipe
import Testing

struct RecipeStore {
    var deletedRecipes: [Recipe] = []
}

struct LocalRecipeLoader {
    let store: RecipeStore
}

struct LocalRecipeCacheTests {
    
    @Test func testCacheInitDoesNotDeleteData() {
        let store = RecipeStore()
        let localRecipeLoader = LocalRecipeLoader(store: store)
        
        #expect(store.deletedRecipes == [])
    }
}
