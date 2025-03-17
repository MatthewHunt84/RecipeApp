//
//  FetchRecipeApp.swift
//  FetchRecipe
//
//  Created by Matt Hunt on 2/7/25.
//

import SwiftUI

@main
struct FetchRecipeApp: App {
    var body: some Scene {
        WindowGroup {
            RecipeListView(getRecipes: RecipeListPreviewHelper.getMockRecipes)
        }
    }
}
