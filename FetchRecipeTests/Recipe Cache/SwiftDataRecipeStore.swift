//
//  SwiftDataRecipeStore.swift
//  FetchRecipeTests
//
//  Created by Matt Hunt on 2/24/25.
//

import Testing
import FetchRecipe
import SwiftData


@MainActor
struct SwiftDataStore {
    
    let container: ModelContainer
    let context: ModelContext
    
    init() {
        self.container = try! ModelContainer(for: SwiftDataLocalRecipe.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        self.context = container.mainContext
    }
    
    func retrieveRecipes() throws -> [LocalRecipe] {
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
}

struct SwiftDataRecipeStore {

    @Test func retrieveDeliversEmptyRecipeArrayOnEmptyCache() async throws {
        let sut = await SwiftDataStore()
        
        let emptyRecipes = try await sut.retrieveRecipes()
        
        #expect(emptyRecipes.isEmpty)
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
