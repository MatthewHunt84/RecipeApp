//
//  RecipeListView.swift
//  FetchRecipe
//
//  Created by Matt Hunt on 3/17/25.
//

import SwiftUI
import Observation

typealias RecipeViewFactory = (Recipe) -> RecipeView

struct RecipeListView: View {
    @State var viewModel: ViewModel
    @State private var searchText = ""
    let makeRecipeView: RecipeViewFactory

    var body: some View {
        
        NavigationStack {
            VStack {
                List {
                    ForEach(searchResults) { recipe in
                        makeRecipeView(recipe)
                    }
                    .listRowBackground(Color(.systemBackground).opacity(0.5))
                }
                .scrollContentBackground(.hidden)
                .background(.blue.gradient)
                .searchable(text: $searchText)
                .refreshable {
                    await viewModel.getRecipes()
                }
            }
            .navigationTitle("Recipes")
        }
        .task {
            await viewModel.getRecipes()
        }
    }
    
    var searchResults: [Recipe] {
        if searchText.isEmpty {
            return viewModel.recipes
        } else {
            return viewModel.recipes.filter { recipe in
                recipe.name.contains(searchText)
            }
        }
    }
}

extension RecipeListView {

    @Observable
    class ViewModel: ObservableObject {
        var recipes: [Recipe] = []
        private let localRecipeLoader: LocalRecipeLoader
        private let remoteRecipeLoader: RemoteRecipeLoader
        private let localImageDataCache: LocalRecipeImageDataLoader
        
        init(localRecipeLoader: LocalRecipeLoader, remoteRecipeLoader: RemoteRecipeLoader, localImageDataCache: LocalRecipeImageDataLoader) {
            self.localRecipeLoader = localRecipeLoader
            self.remoteRecipeLoader = remoteRecipeLoader
            self.localImageDataCache = localImageDataCache
        }
        
        func getRecipes() async {
            do {
                let remoteRecipes = try await remoteRecipeLoader.load()
                try await localRecipeLoader.save(remoteRecipes)
                self.recipes = try await localRecipeLoader.load()
            } catch {
                do {
                    self.recipes = try await localRecipeLoader.load()
                } catch {
                    self.recipes = []
                }
            }
        }

        func cacheImage(data: Data, url: URL) async {
            do {
                try await localImageDataCache.save(data, for: url)
                self.recipes = try await localRecipeLoader.load()
            } catch {
                // Handle save image to cache errors
            }
        }
    }
}

#Preview {
    RecipeListView(viewModel: RecipeListPreviewHelper.mockRecipeListViewModel(),
                   makeRecipeView: RecipeListPreviewHelper.mockRecipeViewFactory)
}




