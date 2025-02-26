//
//  SwiftDataRecipeStore.swift
//  FetchRecipeTests
//
//  Created by Matt Hunt on 2/24/25.
//

import Testing
import FetchRecipe
import SwiftData
import Foundation


@ModelActor
actor SwiftDataStore {
    
    func retrieveRecipes() throws -> [LocalRecipe] {
        let context = ModelContext(modelContainer)
        let descriptor = FetchDescriptor<SwiftDataLocalRecipe>()
        let swiftDataModels: [SwiftDataLocalRecipe] = try context.fetch(descriptor)
        return swiftDataModels.map { LocalRecipe(
            cuisine: $0.cuisine,
            name: $0.name,
            photoUrlLarge: $0.photoUrlLarge,
            photoUrlSmall: $0.photoUrlSmall,
            uuid: $0.uuid,
            sourceUrl: $0.sourceUrl,
            youtubeUrl: $0.youtubeUrl)
        }
    }
    
    func insertRecipes(_ recipes: [LocalRecipe]) async throws {
        let context = ModelContext(modelContainer)
        let swiftDataModels = recipes.map {
            SwiftDataLocalRecipe(
                cuisine: $0.cuisine,
                name: $0.name,
                photoUrlLarge: $0.photoUrlLarge,
                photoUrlSmall: $0.photoUrlSmall,
                uuid: $0.uuid,
                sourceUrl: $0.sourceUrl,
                youtubeUrl: $0.youtubeUrl)
        }
        print(swiftDataModels.count)
        swiftDataModels.forEach { model in
            context.insert(model)
        }
        try context.save()
    }
}

struct SwiftDataRecipeStore {

    @Test func retrieveDeliversEmptyRecipeArrayOnEmptyCache() async throws {
        let container = try! ModelContainer(for: SwiftDataLocalRecipe.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let sut = SwiftDataStore(modelContainer: container)
        
        let emptyRecipes = try await sut.retrieveRecipes()
        
        #expect(emptyRecipes.isEmpty)
    }
    
    @Test func multipleRetrieveCallsHaveNoSideEffectsOnEmptyCache() async throws {
        let container = try! ModelContainer(for: SwiftDataLocalRecipe.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let sut = SwiftDataStore(modelContainer: container)
        
        let emptyRecipes = try await sut.retrieveRecipes()
        let emptyRecipes2 = try await sut.retrieveRecipes()
        let emptyRecipes3 = try await sut.retrieveRecipes()
        
        #expect(emptyRecipes.isEmpty)
        #expect(emptyRecipes2.isEmpty)
        #expect(emptyRecipes3.isEmpty)
    }
    
    @Test func retrieveAfterInsertingToEmptyCacheDeliversInsertedRecipes() async throws {
        let container = try! ModelContainer(for: SwiftDataLocalRecipe.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let sut = SwiftDataStore(modelContainer: container)
        let recipe1 = LocalRecipe(
            cuisine: "Any",
            name: "Any",
            photoUrlLarge: nil,
            photoUrlSmall: nil,
            uuid: UUID().uuidString,
            sourceUrl: nil,
            youtubeUrl: nil)
        
        let recipe2 = LocalRecipe(
            cuisine: "Any",
            name: "Any",
            photoUrlLarge: nil,
            photoUrlSmall: nil,
            uuid: UUID().uuidString,
            sourceUrl: nil,
            youtubeUrl: nil)
        
        let insertedRecipes = [recipe1, recipe2]
        
        try await sut.insertRecipes(insertedRecipes)
        let retrievedRecipes = try await sut.retrieveRecipes()
        
        #expect(retrievedRecipes.sorted() == insertedRecipes.sorted())
    }
}

@Model
class SwiftDataLocalRecipe {
     var cuisine: String
     var name: String
     var photoUrlLarge: String?
     var photoUrlSmall: String?
     var uuid: String
     var sourceUrl: String?
     var youtubeUrl: String?
    
    init(cuisine: String, name: String, photoUrlLarge: String?, photoUrlSmall: String?, uuid: String, sourceUrl: String?, youtubeUrl: String?) {
        self.cuisine = cuisine
        self.name = name
        self.photoUrlLarge = photoUrlLarge
        self.photoUrlSmall = photoUrlSmall
        self.uuid = uuid
        self.sourceUrl = sourceUrl
        self.youtubeUrl = youtubeUrl
    }
}
