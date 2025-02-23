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
    
    func stubDeletionResult(_ result: Result<LocalRecipe, Error>) {
        deletionStubs.append(result)
    }
    
    func stubInsertionResult(_ result: Result<LocalRecipe, Error>) {
        insertionStubs.append(result)
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
        return savedRecipes
    }
}
