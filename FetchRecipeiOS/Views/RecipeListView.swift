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
    @Environment(\.colorScheme) var colorScheme
    @State var viewModel: ViewModel
    let makeRecipeView: RecipeViewFactory
    
    var body: some View {
        
        NavigationStack {
            VStack {
                List {
                    ForEach(viewModel.filteredRecipes) { recipe in
                        makeRecipeView(recipe)
                    }
                    .listRowBackground(viewModel.listBackground)
                }
                .scrollContentBackground(.hidden)
                .searchable(text: $viewModel.searchText)
                .background(colorScheme == .dark ?
                            viewModel.darkModePurpleBackground : viewModel.lightModeBlueBackground)
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
}

extension RecipeListView {
    
    @Observable
    class ViewModel: ObservableObject {
        
        private let localRecipeLoader: LocalRecipeLoader
        private let remoteRecipeLoader: RemoteRecipeLoader
        private let localImageDataCache: LocalRecipeImageDataLoader
        
        let darkModePurpleBackground = Color.purple.mix(with: .black, by: 0.55).gradient
        let lightModeBlueBackground = Color.blue.gradient
        let listBackground = Color(.systemBackground).opacity(0.65)
        
        var searchText: String = ""
        var recipes: [Recipe] = []
        
        init(localRecipeLoader: LocalRecipeLoader, remoteRecipeLoader: RemoteRecipeLoader, localImageDataCache: LocalRecipeImageDataLoader) {
            self.localRecipeLoader = localRecipeLoader
            self.remoteRecipeLoader = remoteRecipeLoader
            self.localImageDataCache = localImageDataCache
        }
        
        var filteredRecipes: [Recipe] {
            if searchText.isEmpty {
                return recipes
            } else {
                return recipes.filter { recipe in
                    recipe.name.localizedStandardContains(searchText)
                }
            }
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
            try? await localImageDataCache.save(data, for: url)
            do {
                self.recipes = try await localRecipeLoader.load()
            } catch {
                self.recipes = []
            }
        }
    }
}

#Preview {
    RecipeListView(viewModel: RecipeListPreviewHelper.mockRecipeListViewModel(),
                   makeRecipeView: RecipeListPreviewHelper.mockRecipeViewFactory)
}




