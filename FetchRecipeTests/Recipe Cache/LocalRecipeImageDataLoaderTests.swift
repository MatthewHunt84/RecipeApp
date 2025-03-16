//
//  LocalRecipeImageDataLoaderTests.swift
//  FetchRecipeTests
//
//  Created by Matt Hunt on 3/15/25.
//

import Testing
import FetchRecipe
import Foundation


struct LocalRecipeImageDataLoaderTests {

    @Test func init_shouldNotAttemptStoreRetrieval() async throws {
        let (_ ,store) = makeSUT()
        
        #expect(store.insertedImages.isEmpty)
        #expect(store.retrievedImages.isEmpty)
    }
    
    @Test func loadImageData_withStoreRetrievalError_shouldThrowError() async throws {
        let (sut, store) = makeSUT()
        let url = try anyURL()
        let error = NSError(domain: "loadError", code: 0)
        
        store.stubRetrievalResult(url: url, with: .failure(error))
        
        await #expect(throws: LocalRecipeImageDataLoader.Error.failedToLoad) {
            try await sut.loadImageData(for: url)
        }
    }
    
    @Test func loadImageData_withNilData_shouldReturnNilWithoutError() async throws {
        let (sut, store) = makeSUT()
        let url = try anyURL()
        
        store.stubRetrievalResult(url: url, with: .success(nil))
        
        let result = try await sut.loadImageData(for: url)
        #expect(result == nil)
    }
    
    @Test func loadImageData_withEmptyCache_shouldReturnNil() async throws {
        let (sut, store) = makeSUT()
        let url = try anyURL()
        
        #expect(store.insertedImages.isEmpty)
        
        let result = try await sut.loadImageData(for: url)
        #expect(result == nil)
    }
    
    @Test func loadImageData_withCachedImageData_shouldReturnImageData() async throws {
        let (sut, store) = makeSUT()
        let url = try anyURL()
        let data = try mockUniqueImageData()
        
        store.stubRetrievalResult(url: url, with: .success(data))
        
        let result = try await sut.loadImageData(for: url)
        #expect(result == data)
    }
    
    @Test func save_withSaveError_shouldThrowError() async throws {
        let (sut, store) = makeSUT()
        let url = try anyURL()
        let data = try mockUniqueImageData()
        
        let error = NSError(domain: "saveError", code: 0)
        store.stubInsertionResult(url: url, with: .failure(error))
        
        await #expect(throws: LocalRecipeImageDataLoader.Error.failedToSave) {
            try await sut.save(data, for: url)
        }
    }
    
    @Test func save_withSaveError_shouldNotAddAnyDataToCache() async throws {
        let (sut, store) = makeSUT()
        let url = try anyURL()
        let data = try mockUniqueImageData()
        
        let error = NSError(domain: "saveError", code: 0)
        store.stubInsertionResult(url: url, with: .failure(error))
        
        await #expect(throws: LocalRecipeImageDataLoader.Error.failedToSave) {
            try await sut.save(data, for: url)
        }
        
        #expect(store.insertedImages.isEmpty)
    }
    
    @Test func save_withNoError_shouldAddAnyDataToCacheSuccessfully() async throws {
        let (sut, store) = makeSUT()
        let url = try anyURL()
        let data = try mockUniqueImageData()
        
        store.stubInsertionResult(url: url, with: .success(data))
        
        try await sut.save(data, for: url)
        
        #expect(store.insertedImages.count == 1)
        #expect(store.insertedImages.first == data)
    }
    
    // MARK: Helpers
    
    private func makeSUT() -> (sut: LocalRecipeImageDataLoader, store: RecipeImageDataStoreSpy) {
        let store = RecipeImageDataStoreSpy()
        let sut = LocalRecipeImageDataLoader(store: store)
        #expect(store.insertedImages.isEmpty)
        return (sut, store)
    }
    
    
    private class RecipeImageDataStoreSpy: RecipeImageDataStore {
        var insertedImages: [Data?] = []
        var retrievedImages: [Data?] = []
        
        private var insertionStubs: [(url: URL, result: Result<Data?, Error>)] = []
        private var retrievalStubs: [(url: URL, result: Result<Data?, Error>)] = []
        
        func stubInsertionResult(url: URL, with result: Result<Data?, Error>) {
            insertionStubs.append((url, result))
        }
        
        func stubRetrievalResult(url: URL, with result: Result<Data?, Error>) {
            retrievalStubs.append((url, result))
        }
        
        func insert(_ data: Data, for url: URL) async throws {
            let result = try #require(insertionStubs.first(where: { $0.url == url })?.result)
            switch result {
            case .success(let data):
                insertedImages.append(data)
            case .failure(let error):
                throw error
            }
        }
        
        func retrieveData(for url: URL) async throws -> Data? {
            guard let result = retrievalStubs.first(where: { $0.url == url })?.result else {
                return nil
            }
            switch result {
            case .success(let data):
                retrievedImages.append(data)
                return data
            case .failure(let error):
                throw error
            }
        }
    }
}
