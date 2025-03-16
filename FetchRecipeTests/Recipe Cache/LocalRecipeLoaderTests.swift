//
//  LocalRecipeLoaderTests.swift
//  FetchRecipeTests
//
//  Created by Matt Hunt on 2/23/25.
//

import FetchRecipe
import Testing
import Foundation

struct LocalRecipeLoaderTests {

    @Test func init_withNewCache_shouldNotLoadOrDeleteRecipes() {
        let (_, store) = makeSUT()
        
        #expect(store.savedRecipes == [])
        #expect(store.deletedRecipes == [])
    }
    
    @Test func load_withRetrievalError_shouldThrowError() async throws {
        let (sut, store) = makeSUT()
        let retrievalError = NSError(domain: "Cache Retrieval Error", code: 0)
        store.stubRetrievalResult(.failure(retrievalError))
        
        await #expect(throws: retrievalError) {
            let _ = try await sut.load()
        }
    }
    
    @Test func load_withEmptyCache_shouldReturnEmptyRecipeArray() async throws {
        let (sut, store) = makeSUT()
        try #require(store.savedRecipes.isEmpty)
        
        let recipes = try await sut.load()
        
        #expect(recipes.isEmpty)
    }
    
    @Test func load_withCachedRecipes_shouldReturnCachedRecipes() async throws {
        let (sut, store) = makeSUT()
        let savedRecipes = makeUniqueRecipes()
        store.stubRetrievalResult(.success(savedRecipes.local))
        
        let recipes = try await sut.load()
        
        #expect(recipes == savedRecipes.models)
    }
    
    @Test func save_withCachedRecipes_shouldDeletePreviouslyCachedRecipes() async throws {
        let (sut, store) = makeSUT()
        let recipe1 = [makeUniqueRecipe()]
        let recipe2 = [makeUniqueRecipe()]
        
        try await sut.save(recipe1)
        try await sut.save(recipe2)
        
        #expect(store.deletedRecipes.count == 1)
    }
    
    @Test func save_withDeletionError_shouldNotSaveRecipesToCache() async throws {
        let (sut, store) = makeSUT()
        let recipes = makeUniqueRecipes()
        let deletionError = NSError(domain: "Deletion Error", code: 0)
        
        store.stubDeletionResult(.failure(deletionError))
        
        await #expect(throws: deletionError) {
            try await sut.save(recipes.models)
        }
        
        #expect(store.savedRecipes.count == 0)
    }

    @Test func save_withSuccessfulCacheDeletion_shouldSaveLatestRecipes() async throws {
        let (sut, store) = makeSUT()
        let recipes = makeUniqueRecipes()
        
        try await sut.save(recipes.models)
        
        #expect(store.savedRecipes == recipes.local)
    }

    @Test func save_withSaveError_shouldNotSaveRecipes() async throws {
        let (sut, store) = makeSUT()
        let recipes = makeUniqueRecipes()
        let saveError = NSError(domain: "Save Error", code: 0)
        
        store.stubInsertionResult(.failure(saveError))
        
        await #expect(throws: saveError) {
            try await sut.save(recipes.models)
        }
        
        #expect(store.savedRecipes.isEmpty)
    }
    
    // MARK: Helpers
    
    func makeSUT() -> (LocalRecipeLoader, RecipeStoreSpy) {
        let store = RecipeStoreSpy()
        let localRecipeLoader = LocalRecipeLoader(store: store)
        return (localRecipeLoader, store)
    }

    func makeUniqueRecipes() -> (models: [Recipe], local: [LocalRecipe]) {
        let models = [makeUniqueRecipe(), makeUniqueRecipe()]
        let local = models.map { LocalRecipe(
            cuisine: $0.cuisine,
            name: $0.name,
            photoUrlLarge: $0.photoUrlLarge,
            photoUrlSmall: $0.photoUrlSmall,
            uuid: $0.id,
            sourceUrl: $0.sourceUrl,
            youtubeUrl: $0.youtubeUrl)
        }
        return (models, local)
    }

    func makeUniqueRecipe() -> Recipe {
        Recipe(cuisine: "any",
               name: "any",
               photoUrlLarge: nil,
               photoUrlSmall: nil,
               id: UUID().uuidString,
               sourceUrl: nil,
               youtubeUrl: nil)
    }
    
    final class RecipeStoreSpy: RecipeStore {
        var deletedRecipes: [LocalRecipe] = []
        var savedRecipes: [LocalRecipe] = []

        private var deletionStubs: [Result<LocalRecipe, Error>] = []
        private var insertionStubs: [Result<LocalRecipe, Error>] = []
        private var retrievalStubs: [Result<[LocalRecipe], Error>] = []
        
        func stubDeletionResult(_ result: Result<LocalRecipe, Error>) {
            deletionStubs.append(result)
        }
        
        func stubInsertionResult(_ result: Result<LocalRecipe, Error>) {
            insertionStubs.append(result)
        }
        
        func stubRetrievalResult(_ result: Result<[LocalRecipe], Error>) {
            retrievalStubs.append(result)
            if case .success(let recipes) = result {
                savedRecipes.append(contentsOf: recipes)
            }
        }
        
        func deleteCachedRecipes() throws {
            if case .failure(let error) = deletionStubs.first {
                throw error
            }
            deletedRecipes.append(contentsOf: savedRecipes)
            savedRecipes.removeAll()
        }
        
        func insertRecipes(_ recipes: [LocalRecipe]) throws {
            if case .failure(let error) = insertionStubs.first {
                throw error
            }
            savedRecipes.append(contentsOf: recipes)
        }
        
        func retrieveRecipes() throws -> [LocalRecipe] {
            if case .failure(let error) = retrievalStubs.first {
                throw error
            }
            return savedRecipes
        }
    }
}
