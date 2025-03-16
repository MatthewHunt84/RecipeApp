//
//  LocalRecipeImageDataStore.swift
//  FetchRecipe
//
//  Created by Matt Hunt on 3/16/25.
//

import Foundation

public protocol RecipeImageDataStore {
    func insert(_ data: Data, for url: URL) async throws
    func retrieveData(for url: URL) async throws -> Data?
}
