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

    var deletionStubs: [Result<Recipe, Error>] = []
    var insertionStubs: [Result<Recipe, Error>] = []
    
    func stubDeletionResult(_ result: Result<Recipe, Error>) {
        deletionStubs.append(result)
    }
    
    func stubInsertionResult(_ result: Result<Recipe, Error>) {
        insertionStubs.append(result)
    }
    
    func deleteCachedRecipes() throws {
        if case .failure(let error) = deletionStubs.first {
            throw error
        }
        deletedRecipes.append(contentsOf: savedRecipes)
        savedRecipes.removeAll()
    }
    
    func insertRecipes(_ recipes: [Recipe]) throws {
        if case .failure(let error) = insertionStubs.first {
            throw error
        }
        savedRecipes.append(contentsOf: recipes)
    }
}

struct LocalRecipeLoader {
    let store: RecipeStore
    
    func save(_ recipes: [Recipe]) throws {
        try store.deleteCachedRecipes()
        try store.insertRecipes(recipes)
    }
}

struct LocalRecipeCacheTests {
    
    @Test func testCacheInitDoesNotDeleteSavedRecipes() {
        let (_, store) = makeSUT()
        
        #expect(store.deletedRecipes == [])
    }
    
    @Test func testSaveNewRecipeRequestsDeletionOfCachedRecipes() throws {
        let (sut, store) = makeSUT()
        let uniqueRecipe = [makeUniqueRecipe()]
        
        try sut.save(uniqueRecipe)
        try sut.save(uniqueRecipe)
        
        #expect(store.deletedRecipes.count == 1)
    }
    
    @Test func testDeletionErrorPreventsSavingNewRecipesToCache() throws {
        let (sut, store) = makeSUT()
        let uniqueRecipe = [makeUniqueRecipe()]
        let deletionError = NSError(domain: "Deletion Error", code: 0)
        
        store.stubDeletionResult(.failure(deletionError))
        
        #expect(throws: deletionError) {
            try sut.save(uniqueRecipe)
        }
        
        #expect(store.savedRecipes.count == 0)
    }

    @Test func testDeletionSuccessPreceedsSuccessfullySavingRecipes() throws {
        let (sut, store) = makeSUT()
        let uniqueRecipes = [makeUniqueRecipe(), makeUniqueRecipe()]
        
        try sut.save(uniqueRecipes)
        
        #expect(store.savedRecipes == uniqueRecipes)
    }
    
    @Test func testSaveFailsOnSaveError() throws {
        let (sut, store) = makeSUT()
        let uniqueRecipe = [makeUniqueRecipe()]
        let saveError = NSError(domain: "Save Error", code: 0)
        
        store.stubInsertionResult(.failure(saveError))
        
        #expect(throws: saveError) {
            try sut.save(uniqueRecipe)
        }
        
        #expect(store.savedRecipes.isEmpty)
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
