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
        let recipes = makeUniqueRecipes()
        let deletionError = NSError(domain: "Deletion Error", code: 0)
        
        store.stubDeletionResult(.failure(deletionError))
        
        #expect(throws: deletionError) {
            try sut.save(recipes.models)
        }
        
        #expect(store.savedRecipes.count == 0)
    }

    @Test func testDeletionSuccessPrecedesSuccessfullySavingRecipes() throws {
        let (sut, store) = makeSUT()
        let recipes = makeUniqueRecipes()
        
        try sut.save(recipes.models)
        
        #expect(store.savedRecipes == recipes.local)
    }

    @Test func testSaveFailsOnSaveError() throws {
        let (sut, store) = makeSUT()
        let recipes = makeUniqueRecipes()
        let saveError = NSError(domain: "Save Error", code: 0)
        
        store.stubInsertionResult(.failure(saveError))
        
        #expect(throws: saveError) {
            try sut.save(recipes.models)
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
    
    func makeUniqueRecipes() -> (models: [Recipe], local: [LocalRecipe]) {
        let models = [makeUniqueRecipe(), makeUniqueRecipe()]
        let local = models.map { LocalRecipe(
            cuisine: $0.cuisine,
            name: $0.name,
            photoUrlLarge: $0.photoUrlLarge,
            photoUrlSmall: $0.photoUrlSmall,
            uuid: $0.uuid,
            sourceUrl: $0.sourceUrl,
            youtubeUrl: $0.youtubeUrl)
        }
        return (models, local)
    }
}




