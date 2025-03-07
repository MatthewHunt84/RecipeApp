//
//  SharedTestHelpers.swift
//  FetchRecipe
//
//  Created by Matt Hunt on 3/7/25.
//

import FetchRecipe
import Foundation

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
