//
//  RecipeImageDataStoreTests.swift
//  FetchRecipeTests
//
//  Created by Matt Hunt on 3/16/25.
//

import Testing
import FetchRecipe
import Foundation
import SwiftData

extension SwiftDataStore {
    func retrieveData(for: URL) async throws -> Data? {
        return nil
    }
}

struct SwiftDataRecipeImageDataStoreTests {

    @Test func retrieveData_withEmptyStore_shouldReturnNil() async throws {
        let container = try ModelContainer(for: SwiftDataLocalRecipe.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let sut = SwiftDataStore(modelContainer: container)
        let url = try anyURL()
        
        let result = try await sut.retrieveData(for: url)
        
        #expect(result == nil)
    }

}
