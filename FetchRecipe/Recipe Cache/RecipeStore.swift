//
//  RecipeStore.swift
//  FetchRecipe
//
//  Created by Matt Hunt on 2/22/25.
//

import Foundation

protocol RecipeStore {
    func deleteCachedRecipes() throws
    func saveRecipes(_ recipes: [Recipe]) throws
}
