//
//  RecipeStore.swift
//  FetchRecipe
//
//  Created by Matt Hunt on 2/22/25.
//

import Foundation

public protocol RecipeStore {
    func deleteCachedRecipes() async throws
    func insertRecipes(_ recipes: [LocalRecipe]) async throws
    func retrieveRecipes() async throws -> [LocalRecipe]
}
