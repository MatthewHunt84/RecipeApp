//
//  RecipeStoreSpy.swift
//  FetchRecipe
//
//  Created by Matt Hunt on 2/23/25.
//

import Foundation
import FetchRecipe

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
