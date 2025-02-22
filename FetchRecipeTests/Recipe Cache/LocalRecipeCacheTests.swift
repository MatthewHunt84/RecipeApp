//
//  LocalRecipeCacheTests.swift
//  FetchRecipeTests
//
//  Created by Matt Hunt on 2/22/25.
//

import Foundation
import FetchRecipe
import Testing

struct LocalRecipeCacheTests {
    
    @Test func testCacheInitDoesNotDeleteSavedRecipes() {
        let (_, store) = makeSUT()
        
        #expect(store.deletedRecipes == [])
    }
    
    @Test func testSaveNewRecipeRequestsDeletionOfCachedRecipes() throws {
        let (sut, store) = makeSUT()
        let recipe1 = [makeUniqueRecipe()]
        let recipe2 = [makeUniqueRecipe()]
        
        try sut.save(recipe1)
        try sut.save(recipe2)
        
        #expect(store.deletedRecipes.count == 1)
    }
    
    @Test func testDeletionErrorPreventsSavingNewRecipesToCache() throws {
        let (sut, store) = makeSUT()
        let recipe = [makeUniqueRecipe()]
        let deletionError = NSError(domain: "Deletion Error", code: 0)
        
        store.stubDeletionResult(.failure(deletionError))
        
        #expect(throws: deletionError) {
            try sut.save(recipe)
        }
        
        #expect(store.savedRecipes.count == 0)
    }

    @Test func testDeletionSuccessPreceedsSuccessfullySavingRecipes() throws {
        let (sut, store) = makeSUT()
        let recipes = [makeUniqueRecipe(), makeUniqueRecipe()]
        
        try sut.save(recipes)
        
        #expect(store.savedRecipes == recipes)
    }
    
    @Test func testSaveFailsOnSaveError() throws {
        let (sut, store) = makeSUT()
        let recipe = [makeUniqueRecipe()]
        let saveError = NSError(domain: "Save Error", code: 0)
        
        store.stubInsertionResult(.failure(saveError))
        
        #expect(throws: saveError) {
            try sut.save(recipe)
        }
        
        #expect(store.savedRecipes.isEmpty)
    }
    
    // MARK: Helpers
    
    func makeSUT() -> (LocalRecipeLoader, RecipeStoreSpy) {
        let store = RecipeStoreSpy()
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
    
    final class RecipeStoreSpy: RecipeStore {
        var deletedRecipes: [Recipe] = []
        var savedRecipes: [Recipe] = []

        private var deletionStubs: [Result<Recipe, Error>] = []
        private var insertionStubs: [Result<Recipe, Error>] = []
        
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
}


