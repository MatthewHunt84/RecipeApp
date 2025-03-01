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
    @Attribute(.unique) var uuid: String
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
actor SwiftDataStore: RecipeStore {
    
    func retrieveRecipes() async throws -> [LocalRecipe] {
        let descriptor = FetchDescriptor<SwiftDataLocalRecipe>()
        let swiftDataModels: [SwiftDataLocalRecipe] = try modelContext.fetch(descriptor)
        return swiftDataModels.map { $0.local }
    }
    
    func insertRecipes(_ recipes: [LocalRecipe]) async throws {
        try await deleteCachedRecipes()
        let swiftDataModels = recipes.map(SwiftDataLocalRecipe.init)
        swiftDataModels.forEach { model in
            modelContext.insert(model)
        }
        try modelContext.save()
    }
    
    func deleteCachedRecipes() async throws {
        try modelContext.delete(model: SwiftDataLocalRecipe.self)
        try modelContext.save()
    }
}

@Suite(.serialized)
struct SwiftDataRecipeStore {

    @Test func retrieveRecipes_withEmptyCache_shouldReturnEmptyArray() async throws {
        let sut = makeSUT()
        
        let emptyRecipes = try await sut.retrieveRecipes()
        
        #expect(emptyRecipes.isEmpty)
    }
    
    @Test func retrieveRecipes_multipleTimesWithEmptyCache_shouldReturnEmptyArrays() async throws {
        let sut = makeSUT()
        
        let emptyRecipes = try await sut.retrieveRecipes()
        let emptyRecipes2 = try await sut.retrieveRecipes()
        let emptyRecipes3 = try await sut.retrieveRecipes()
        
        #expect(emptyRecipes.isEmpty)
        #expect(emptyRecipes2.isEmpty)
        #expect(emptyRecipes3.isEmpty)
    }
    
    @Test func retrieveRecipes_withCachedRecipes_shouldReturnCachedRecipes() async throws {
        let sut = makeSUT()
        
        let insertedRecipes = makeLocalRecipes()
        
        try await sut.insertRecipes(insertedRecipes)
        let retrievedRecipes = try await sut.retrieveRecipes()
        
        #expect(retrievedRecipes.sorted() == insertedRecipes.sorted())
    }
    
    @Test func retrieveRecipes_multipleTimesWithCachedRecipes_shouldReturnCachedRecipes() async throws {
        let sut = makeSUT()
        
        let insertedRecipes = makeLocalRecipes()
        
        try await sut.insertRecipes(insertedRecipes)
        let firstRetrievedRecipes = try await sut.retrieveRecipes()
        let secondRetrievedRecipes = try await sut.retrieveRecipes()
        
        #expect(firstRetrievedRecipes.sorted() == secondRetrievedRecipes.sorted())
    }
    
    @Test func insertRecipes_overridesPreviouslyInsertedRecipes() async throws {
        let sut = makeSUT()
        let firstRecipes = makeLocalRecipes()
        let secondRecipes = makeLocalRecipes()
        
        try await sut.insertRecipes(firstRecipes)
        try await sut.insertRecipes(secondRecipes)
        let storedRecipes = try await sut.retrieveRecipes()
        
        #expect(storedRecipes.sorted() == secondRecipes.sorted())
    }
    
    @Test func insertRecipes_withDuplicateRecipes_shouldNotInsertDuplicates() async throws {
        let sut = makeSUT()
        let recipesWithDuplicate = makeLocalRecipesWithDuplicates()
        try #require(recipesWithDuplicate.count == 2)
        
        try await sut.insertRecipes(recipesWithDuplicate)
        let retrievedRecipes = try await sut.retrieveRecipes()
        
        #expect(retrievedRecipes.count ==  1)
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
        (0..<Int.random(in: 1...10)).map { _ in makeLocalRecipe() }
    }

    func makeLocalRecipesWithDuplicates() -> [LocalRecipe] {
        let originalRecipe = makeLocalRecipe()
        let duplicateRecipe = LocalRecipe(
            cuisine: originalRecipe.cuisine,
            name: originalRecipe.cuisine,
            photoUrlLarge: originalRecipe.photoUrlLarge,
            photoUrlSmall: originalRecipe.photoUrlSmall,
            uuid: originalRecipe.uuid,
            sourceUrl: originalRecipe.sourceUrl,
            youtubeUrl: originalRecipe.youtubeUrl)
        
        return [originalRecipe, duplicateRecipe]
    }
}
