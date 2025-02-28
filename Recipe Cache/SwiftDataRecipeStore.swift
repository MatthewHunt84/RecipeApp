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

@Model
class SwiftDataLocalRecipe {
     var cuisine: String
     var name: String
     var photoUrlLarge: String?
     var photoUrlSmall: String?
     var uuid: String
     var sourceUrl: String?
     var youtubeUrl: String?
    
    init(cuisine: String,
         name: String,
         photoUrlLarge: String?,
         photoUrlSmall: String?,
         uuid: String,
         sourceUrl: String?,
         youtubeUrl: String?) {
        self.cuisine = cuisine
        self.name = name
        self.photoUrlLarge = photoUrlLarge
        self.photoUrlSmall = photoUrlSmall
        self.uuid = uuid
        self.sourceUrl = sourceUrl
        self.youtubeUrl = youtubeUrl
    }
    
    var local: LocalRecipe {
        LocalRecipe(
            cuisine: cuisine,
            name: name,
            photoUrlLarge: photoUrlLarge,
            photoUrlSmall: photoUrlSmall,
            uuid: uuid,
            sourceUrl: sourceUrl,
            youtubeUrl: youtubeUrl)
    }
    
    init(_ localRecipe: LocalRecipe) {
        self.cuisine = localRecipe.cuisine
        self.name = localRecipe.name
        self.photoUrlLarge = localRecipe.photoUrlLarge
        self.photoUrlSmall = localRecipe.photoUrlSmall
        self.uuid = localRecipe.uuid
        self.sourceUrl = localRecipe.sourceUrl
        self.youtubeUrl = localRecipe.youtubeUrl
    }
}

@ModelActor
actor SwiftDataStore {
    
    func retrieveRecipes() throws -> [LocalRecipe] {
        let context = ModelContext(modelContainer)
        let descriptor = FetchDescriptor<SwiftDataLocalRecipe>()
        let swiftDataModels: [SwiftDataLocalRecipe] = try context.fetch(descriptor)
        return swiftDataModels.map { $0.local }
    }
    
    func insertRecipes(_ recipes: [LocalRecipe]) async throws {
        let context = ModelContext(modelContainer)
        let swiftDataModels = recipes.map(SwiftDataLocalRecipe.init)
        print(swiftDataModels.count)
        swiftDataModels.forEach { model in
            context.insert(model)
        }
        try context.save()
    }
}

struct SwiftDataRecipeStore {

    @Test func retrieveDeliversEmptyRecipeArrayOnEmptyCache() async throws {
        let sut = makeSUT()
        
        let emptyRecipes = try await sut.retrieveRecipes()
        
        #expect(emptyRecipes.isEmpty)
    }
    
    @Test func multipleRetrieveCallsHaveNoSideEffectsOnEmptyCache() async throws {
        let sut = makeSUT()
        
        let emptyRecipes = try await sut.retrieveRecipes()
        let emptyRecipes2 = try await sut.retrieveRecipes()
        let emptyRecipes3 = try await sut.retrieveRecipes()
        
        #expect(emptyRecipes.isEmpty)
        #expect(emptyRecipes2.isEmpty)
        #expect(emptyRecipes3.isEmpty)
    }
    
    @Test func retrieveAfterInsertingToEmptyCacheDeliversInsertedRecipes() async throws {
        let sut = makeSUT()
        
        let insertedRecipes = makeLocalRecipes()
        
        try await sut.insertRecipes(insertedRecipes)
        let retrievedRecipes = try await sut.retrieveRecipes()
        
        #expect(retrievedRecipes.sorted() == insertedRecipes.sorted())
    }
    
    @Test func retrieveFromCacheTwiceHasNoSideEffects() async throws {
        let sut = makeSUT()
        let insertedRecipes = makeLocalRecipes()
        
        try await sut.insertRecipes(insertedRecipes)
        let firstRetrievedRecipes = try await sut.retrieveRecipes()
        let secondRetrievedRecipes = try await sut.retrieveRecipes()
        
        #expect(firstRetrievedRecipes.sorted() == secondRetrievedRecipes.sorted())
    }
    
    // MARK: Helpers
    
    func makeSUT() -> SwiftDataStore {
        let container = try! ModelContainer(for: SwiftDataLocalRecipe.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let sut = SwiftDataStore(modelContainer: container)
        return sut
    }
    
    func makeLocalRecipe() -> LocalRecipe {
        LocalRecipe(
            cuisine: "Any",
            name: "Any",
            photoUrlLarge: nil,
            photoUrlSmall: nil,
            uuid: UUID().uuidString,
            sourceUrl: nil,
            youtubeUrl: nil)
    }
    
    func makeLocalRecipes() -> [LocalRecipe] {
        
        let numberOfRecipes = Int.random(in: 1...10)
        let recipes = Array(repeating: makeLocalRecipe(), count: numberOfRecipes)
        
        return recipes
    }
}
