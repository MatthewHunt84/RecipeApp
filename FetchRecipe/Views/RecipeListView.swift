//
//  RecipeListView.swift
//  FetchRecipe
//
//  Created by Matt Hunt on 3/17/25.
//

import SwiftUI

struct RecipeListView: View {
    @State var recipes: [Recipe]
    @State private var searchText = ""
    let getRecipes: () async -> [Recipe]

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(searchResults) { recipe in
                        RecipeView(recipe: recipe)
                    }
                }
                .searchable(text: $searchText)
                .refreshable {
                    recipes = await getRecipes()
                }
            }
            .navigationTitle("Recipes")

        }
        .task {
            recipes = await getRecipes()
        }
    }
    
    var searchResults: [Recipe] {
        if searchText.isEmpty {
            return recipes
        } else {
            return recipes.filter { recipe in
                recipe.name.contains(searchText)
            }
        }
    }
}

#Preview {
    RecipeListView(
        recipes: [],
        getRecipes: RecipeListPreviewHelper.getMockRecipes)
}




