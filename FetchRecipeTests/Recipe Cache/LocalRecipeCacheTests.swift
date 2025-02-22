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
    var insertionCallCount = 0
    var results: [Result<Recipe, Error>] = []
    
    func stub(_ result: Result<Recipe, Error>) {
        results.append(result)
    }
    
    func deleteCachedRecipes() throws {
        if case .failure(let error) = results.first {
            throw error
        }
        deletionCallCount += 1
    }
    
    func saveRecipes() {
        insertionCallCount += 1
    }
}

struct LocalRecipeLoader {
    let store: RecipeStore
    
    func save(_ recipe: Recipe) throws {
        try store.deleteCachedRecipes()
    }
}

struct LocalRecipeCacheTests {
    
    @Test func testCacheInitDoesNotDeleteData() {
        let (_, store) = makeSUT()
        
        #expect(store.deletedRecipes == [])
    }
    
    @Test func testNewSaveRequestsDeletionOfOldCachedRecipes() throws {
        let (sut, store) = makeSUT()
        let uniqueRecipe = makeUniqueRecipe()
        
        try sut.save(uniqueRecipe)
        
        #expect(store.deletionCallCount == 1)
    }
    
    @Test func testCacheDoesNotRequestCacheInsertionOnDeletionError() throws {
        let (sut, store) = makeSUT()
        let uniqueRecipe = makeUniqueRecipe()
        let error = NSError(domain: "Deletion Error", code: 0)
        
        store.stub(.failure(error))
        
        #expect(throws: error) {
            try sut.save(uniqueRecipe)
        }
        
        #expect(store.insertionCallCount == 0)
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
