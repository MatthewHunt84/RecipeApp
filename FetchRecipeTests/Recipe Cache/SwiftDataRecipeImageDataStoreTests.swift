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


@Suite(.serialized)
struct SwiftDataRecipeImageDataStoreTests {

    @Test func insert_withUrlNotFoundInRecipeStore_shouldThrowUrlNotFoundError() async throws {
        let sut = try makeSUT()
        let url = try anyURL()
        try await addRecipe(to: sut, urlString: nil)
        let imageData = try mockUniqueImageData()
        
        await #expect(throws: SwiftDataStore.Error.urlNotFound) {
            try await sut.insert(imageData, for: url)
        }
    }
    
    @Test func insert_withImageDataMatchingUrl_shouldInsertAndRetrieveSuccessfully() async throws {
        let sut = try makeSUT()
        let uniqueUrl = try makeUrl()
        try await addRecipe(to: sut, urlString: uniqueUrl.urlString)
        let imageData = try mockUniqueImageData()
        
        try await sut.insert(imageData, for: uniqueUrl.url)
        let retrievedData = try await sut.retrieveData(for: uniqueUrl.url)
        
        #expect(retrievedData == imageData)
    }
    
    @Test func insert_withNewImageData_shouldOverridePreviouslyInsertedImageData() async throws {
        let sut = try makeSUT()
        let uniqueUrl = try makeUrl()
        try await addRecipe(to: sut, urlString: uniqueUrl.urlString)
        let originalImageData = try mockUniqueImageData()
        let replacementImageData = try mockUniqueImageData()
        
        try await sut.insert(originalImageData, for: uniqueUrl.url)
        try await sut.insert(replacementImageData, for: uniqueUrl.url)
        
        let newRetrievedData = try await sut.retrieveData(for: uniqueUrl.url)
        
        #expect(newRetrievedData != originalImageData)
        #expect(newRetrievedData == replacementImageData)
    }
    
    @Test func insert_withDuplicateUrl_shouldThrowDuplicateUrlError() async throws {
        let sut = try makeSUT()
        let uniqueUrl = try makeUrl()
        try await addMultipleUniqueRecipesWithSameImageURL(to: sut, urlString: uniqueUrl.urlString)
        let imageData = try mockUniqueImageData()
        
        await #expect(throws: SwiftDataStore.Error.duplicateUrl) {
            try await sut.insert(imageData, for: uniqueUrl.url)
        }
    }
    
    @Test func retrieveData_withEmptyRecipeStore_shouldThrowUrlNotFoundError() async throws {
        let sut = try makeSUT()
        let url = try anyURL()
        let imageData = try mockUniqueImageData()
        
        await #expect(throws: SwiftDataStore.Error.urlNotFound) {
            try await sut.insert(imageData, for: url)
        }
    }

    @Test func retrieveData_withUrlNotFoundInRecipeStore_shouldReturnNil() async throws {
        let sut = try makeSUT()
        let url = try makeUrl().url
        try await addRecipe(to: sut, urlString: nil)
        
        await #expect(throws: SwiftDataStore.Error.urlNotFound) {
            try await sut.retrieveData(for: url)
        }
    }
    
    @Test func retrieveData_withDuplicateUrl_shouldThrowDuplicateUrlError() async throws {
        let sut = try makeSUT()
        let uniqueUrl = try makeUrl()
        try await addMultipleUniqueRecipesWithSameImageURL(to: sut, urlString: uniqueUrl.urlString)
        
        await #expect(throws: SwiftDataStore.Error.duplicateUrl) {
            try await sut.retrieveData(for: uniqueUrl.url)
        }
    }
    
    // MARK: Helpers
    
    private func makeSUT() throws -> RecipeImageDataStore {
        let container = try ModelContainer(for: SwiftDataLocalRecipe.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let sut = SwiftDataStore(modelContainer: container)
        return sut
    }
    
    private func addRecipe(to store: RecipeImageDataStore, urlString: String?) async throws {
        let insertedRecipe = [makeRecipe(for: urlString)]
        if let swiftDataStore = store as? SwiftDataStore {
            try await swiftDataStore.insertRecipes(insertedRecipe)
        }
    }
    
    private func addMultipleUniqueRecipesWithSameImageURL(to store: RecipeImageDataStore, urlString: String?) async throws {
        let insertedRecipe = [makeRecipe(for: urlString), makeRecipe(for: urlString), makeRecipe(for: urlString)]
        if let swiftDataStore = store as? SwiftDataStore {
            try await swiftDataStore.insertRecipes(insertedRecipe)
        }
    }
    
    private func makeRecipe(for url: String?) -> LocalRecipe {
        LocalRecipe(
            cuisine: "Any",
            name: "Any",
            photoUrlLarge: nil,
            photoUrlSmall: url,
            uuid: UUID().uuidString,
            sourceUrl: nil,
            youtubeUrl: nil,
            photoUrlSmallImageData: nil)
    }
    
    private func makeUrl() throws -> (url: URL, urlString: String) {
            let uniqueURL = "https://imageData-url-\(UUID().uuidString).com"
            let url = try #require(URL(string: uniqueURL))
            return (url, uniqueURL)
    }
}
