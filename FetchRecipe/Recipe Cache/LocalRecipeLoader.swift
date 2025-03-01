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
    
    public func save(_ recipes: [Recipe]) async throws {
        try await store.deleteCachedRecipes()
        try await store.insertRecipes(recipes.mapToLocalRecipe())
    }
    
    public func load() async throws -> [Recipe] {
        try await store
            .retrieveRecipes()
            .mapToRecipe()
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

extension Array where Element == LocalRecipe {
    func mapToRecipe() -> [Recipe] {
        map { Recipe(
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
