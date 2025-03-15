//
//  LocalRecipeImageDataLoaderTests.swift
//  FetchRecipeTests
//
//  Created by Matt Hunt on 3/15/25.
//

import Testing
import FetchRecipe
import Foundation

struct LocalRecipeImageDataLoader {
    let store: Any
}


struct LocalRecipeImageDataLoaderTests {

    @Test func init_shouldNotAttemptStoreRetrieval() async throws {
        let (_ ,store) = makeSUT()
        
        #expect(store.receivedMessages.isEmpty)
    }
    
    // MARK: Helpers
    
    private func makeSUT() -> (sut: LocalRecipeImageDataLoader, store: RecipeImageDataStoreSpy) {
        let store = RecipeImageDataStoreSpy()
        let sut = LocalRecipeImageDataLoader(store: store)
        return (sut, store)
    }
    
    private struct RecipeImageDataStoreSpy {
        let receivedMessages = [Any]()
    }
}
