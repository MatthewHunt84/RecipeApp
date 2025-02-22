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
    var savedRecipes: [Recipe] = []

    var stubs: [Result<Recipe, Error>] = []
    
    func stub(_ result: Result<Recipe, Error>) {
        stubs.append(result)
    }
    
    func deleteCachedRecipes() throws {
        if case .failure(let error) = stubs.first {
            throw error
        }
        deletedRecipes.append(contentsOf: savedRecipes)
        savedRecipes.removeAll()
    }
    
    func saveRecipes(_ recipes: [Recipe]) {
        savedRecipes = recipes
    }
}

struct LocalRecipeLoader {
    let store: RecipeStore
    
    func save(_ recipes: [Recipe]) throws {
        try store.deleteCachedRecipes()
        store.saveRecipes(recipes)
    }
}

struct LocalRecipeCacheTests {
    
    @Test func testCacheInitDoesNotDeleteData() {
        let (_, store) = makeSUT()
        
        #expect(store.deletedRecipes == [])
    }
    
    @Test func testNewSaveRequestsDeletionOfOldCachedRecipes() throws {
        let (sut, store) = makeSUT()
        let uniqueRecipe = [makeUniqueRecipe()]
        
        try sut.save(uniqueRecipe)
        try sut.save(uniqueRecipe)
        
        #expect(store.deletedRecipes.count == 1)
    }
    
    @Test func testCacheDoesNotRequestCacheInsertionOnDeletionError() throws {
        let (sut, store) = makeSUT()
        let uniqueRecipe = [makeUniqueRecipe()]
        let error = NSError(domain: "Deletion Error", code: 0)
        
        store.stub(.failure(error))
        
        #expect(throws: error) {
            try sut.save(uniqueRecipe)
        }
        
        #expect(store.savedRecipes.count == 0)
    }
    
    @Test func testCacheRequestsSaveUponCacheDeletionSuccess() throws {
        let (sut, store) = makeSUT()
        let uniqueRecipe = [makeUniqueRecipe()]
        
        try sut.save(uniqueRecipe)
        
        #expect(store.savedRecipes.count == 1)
    }
    
    @Test func testCacheSuccessfullySavesRecipes() throws {
        let (sut, store) = makeSUT()
        let uniqueRecipes = [makeUniqueRecipe(), makeUniqueRecipe()]
        
        try sut.save(uniqueRecipes)
        
        #expect(store.savedRecipes == uniqueRecipes)
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
