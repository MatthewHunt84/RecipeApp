//
//  LocalRecipeLoader.swift
//  FetchRecipe
//
//  Created by Matt Hunt on 2/22/25.
//

import Foundation

public struct LocalRecipeLoader {
    
    private let store: RecipeStore
    
    public init(store: RecipeStore) {
        self.store = store
    }
    
    public func save(_ recipes: [Recipe]) throws {
        try store.deleteCachedRecipes()
        try store.insertRecipes(recipes)
    }
}
