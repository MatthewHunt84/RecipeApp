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
    
    @Test func testLoadDeliversRecipesFromCache() throws {
        let (sut, store) = makeSUT()
        let savedRecipes = makeUniqueRecipes()
        store.stubRetrievalResult(.success(savedRecipes.local))
        
        let recipes = try sut.load()
        
        #expect(recipes == savedRecipes.models)
    }
    
    func makeSUT() -> (LocalRecipeLoader, RecipeStoreSpy) {
        let store = RecipeStoreSpy()
        let localRecipeLoader = LocalRecipeLoader(store: store)
        return (localRecipeLoader, store)
    }
    
    func makeUniqueLocalRecipe() -> LocalRecipe {
        LocalRecipe(cuisine: "any",
               name: "any",
               photoUrlLarge: nil,
               photoUrlSmall: nil,
               uuid: UUID().uuidString,
               sourceUrl: nil,
               youtubeUrl: nil)
    }
    
    func makeUniqueRecipes() -> (models: [Recipe], local: [LocalRecipe]) {
        let local = [makeUniqueLocalRecipe(), makeUniqueLocalRecipe()]
        let models = local.map { Recipe(
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
