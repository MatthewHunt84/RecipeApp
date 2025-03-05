//
//  SwiftDataStore.swift
//  FetchRecipe
//
//  Created by Matt Hunt on 3/5/25.
//

import Foundation
import SwiftData

@ModelActor
public actor SwiftDataStore: RecipeStore {
    
    public func retrieveRecipes() async throws -> [LocalRecipe] {
        let descriptor = FetchDescriptor<SwiftDataLocalRecipe>()
        let swiftDataModels: [SwiftDataLocalRecipe] = try modelContext.fetch(descriptor)
        return swiftDataModels.map { $0.local }
    }
    
    public func insertRecipes(_ recipes: [LocalRecipe]) async throws {
        try await deleteCachedRecipes()
        let swiftDataModels = recipes.map(SwiftDataLocalRecipe.init)
        swiftDataModels.forEach { model in
            modelContext.insert(model)
        }
        try modelContext.save()
    }
    
    public func deleteCachedRecipes() async throws {
        try modelContext.delete(model: SwiftDataLocalRecipe.self)
        try modelContext.save()
    }
}
