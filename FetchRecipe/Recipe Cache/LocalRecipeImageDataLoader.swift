//
//  LocalRecipeImageDataLoader.swift
//  FetchRecipe
//
//  Created by Matt Hunt on 3/16/25.
//

import Foundation

public struct LocalRecipeImageDataLoader {
    
    public let store: RecipeImageDataStore
    
    public enum Error: Swift.Error {
        case failedToLoad
        case failedToSave
    }
    
    public init(store: RecipeImageDataStore) {
        self.store = store
    }
    
    public func loadImageData(for url: URL) async throws -> Data? {
        do {
            return try await store.retrieveData(for: url)
        } catch {
            throw Error.failedToLoad
        }
    }
    
    public func save(_ data: Data, for url: URL) async throws {
        do {
            try await store.insert(data, for: url)
        } catch {
            throw Error.failedToSave
        }
    }
}
