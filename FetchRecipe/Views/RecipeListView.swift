//
//  RecipeListView.swift
//  FetchRecipe
//
//  Created by Matt Hunt on 3/17/25.
//

import SwiftUI

struct RecipeView: View {
    let recipe: Recipe
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(recipe.name)
                    .font(.headline)
                
                Text(recipe.cuisine)
                    .italic()
                
                if let source = recipe.sourceUrl, let url = URL(string: source) {
                    Link("Source", destination: url)
                }
            }
            
            Spacer()
            
            AsyncImage(url: URL(string: recipe.photoUrlSmall ?? ""), scale: 1) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image.resizable()
                default:
                    EmptyView()
                }
            }
            .frame(width: 128, height: 128)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }
}

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
        getRecipes: RecipeListPreviewHelper().getMockRecipes)
}




