//
//  RecipeLoader.swift
//  FetchRecipe
//
//  Created by Matt Hunt on 2/9/25.
//

import Foundation

protocol RecipeLoader {
    func load() async throws -> [Recipe]
}
