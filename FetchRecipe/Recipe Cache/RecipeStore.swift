//
//  RecipeStore.swift
//  FetchRecipe
//
//  Created by Matt Hunt on 2/22/25.
//

import Foundation

public protocol RecipeStore {
    func deleteCachedRecipes() throws
    func insertRecipes(_ recipes: [Recipe]) throws
}
