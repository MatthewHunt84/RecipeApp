//
//  SharedTestHelpers.swift
//  FetchRecipe
//
//  Created by Matt Hunt on 3/11/25.
//
import Foundation
import FetchRecipe

func makeSUT() -> (LocalRecipeLoader, RecipeStoreSpy) {
    let store = RecipeStoreSpy()
    let localRecipeLoader = LocalRecipeLoader(store: store)
    return (localRecipeLoader, store)
}

func makeUniqueRecipes() -> (models: [Recipe], local: [LocalRecipe]) {
    let models = [makeUniqueRecipe(), makeUniqueRecipe()]
    let local = models.map { LocalRecipe(
        cuisine: $0.cuisine,
        name: $0.name,
        photoUrlLarge: $0.photoUrlLarge,
        photoUrlSmall: $0.photoUrlSmall,
        uuid: $0.id,
        sourceUrl: $0.sourceUrl,
        youtubeUrl: $0.youtubeUrl)
    }
    return (models, local)
}

func makeUniqueRecipe() -> Recipe {
    Recipe(cuisine: "any",
           name: "any",
           photoUrlLarge: nil,
           photoUrlSmall: nil,
           id: UUID().uuidString,
           sourceUrl: nil,
           youtubeUrl: nil)
}

func makeUniqueLocalRecipe() -> LocalRecipe {
    LocalRecipe(cuisine: "any",
           name: "any",
           photoUrlLarge: nil,
           photoUrlSmall: nil,
           uuid: UUID().uuidString,
           sourceUrl: nil,
           youtubeUrl: nil)
}
