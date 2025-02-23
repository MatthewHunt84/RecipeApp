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
        try store.insertRecipes(recipes.mapToLocalRecipe())
    }
}

extension Array where Element == Recipe {
    func mapToLocalRecipe() -> [LocalRecipe] {
        map { LocalRecipe(
            cuisine: $0.cuisine,
            name: $0.name,
            photoUrlLarge: $0.photoUrlLarge,
            photoUrlSmall: $0.photoUrlSmall,
            uuid: $0.uuid,
            sourceUrl: $0.sourceUrl,
            youtubeUrl: $0.youtubeUrl)
        }
    }
}
