//
//  FetchRecipeIntegrationTests.swift
//  FetchRecipeIntegrationTests
//
//  Created by Matt Hunt on 3/5/25.
//

import Testing
import FetchRecipe
import SwiftData

@Suite(.serialized)
struct FetchRecipeIntegrationTests {

    @Test func retrieve_withEmptyCache_shouldReturnEmptyRecipeArray() async throws {
        let sut = await makeSUT()
        
        let recipes = try await sut.retrieveRecipes()

        #expect(recipes.count == 0)
    }

    func makeSUT() async -> SwiftDataStore {
        let container = try! ModelContainer(for: SwiftDataLocalRecipe.self, configurations: ModelConfiguration(isStoredInMemoryOnly: false))
        let sut = SwiftDataStore(modelContainer: container)
        try! await #require(try sut.deleteCachedRecipes())
        return sut
    }
}
