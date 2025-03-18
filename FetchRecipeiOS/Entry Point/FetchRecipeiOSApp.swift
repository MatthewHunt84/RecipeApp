//
//  FetchRecipeiOSApp.swift
//  FetchRecipeiOS
//
//  Created by Matt Hunt on 3/17/25.
//

import SwiftUI
import SwiftData

@main
struct FetchRecipeApp: App {
    
    @State private var compositionRoot = CompositionRoot()
    
    var body: some Scene {
        WindowGroup {
            switch compositionRoot.compositionResult {
            case .success(let recipeListView):
                recipeListView
            case .failure(let error):
                CompositionErrorView(error: error, retryAction: compositionRoot.retryComposition)
            }
        }
    }
}

@Observable
class CompositionRoot {
    
    private static var urlString = "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json"
    private(set) var compositionResult: Result<RecipeListView, Error>
    
    enum CompositionError: Swift.Error {
        case badURL
        case badModelContainer
    }
    
    init() {
        self.compositionResult = Self.composeRecipeListView()
    }
    
    static func composeRecipeListView() -> Result<RecipeListView, Error> {
        do {
            let (localRecipeLoader, remoteRecipeLoader, localImageDataCache) = try getRecipeListViewDependencies()
            
            let viewModel = RecipeListView.ViewModel(
                localRecipeLoader: localRecipeLoader,
                remoteRecipeLoader: remoteRecipeLoader,
                localImageDataCache: localImageDataCache
            )
            
            func makeRecipeView(for recipe: Recipe) -> RecipeView {
                RecipeView(
                    recipe: recipe,
                    cacheImageData: viewModel.cacheImage
                )
            }
            
            return .success(
                RecipeListView(
                    viewModel: viewModel,
                    makeRecipeView: makeRecipeView
                )
            )
        } catch {
            return .failure(error)
        }
    }
    
    static private func getRecipeListViewDependencies() throws -> (LocalRecipeLoader, RemoteRecipeLoader, LocalRecipeImageDataLoader) {
        let url = try createRecipeUrl()
        let modelContainer = try createModelContainer()
        let swiftDataStore = SwiftDataStore(modelContainer: modelContainer)
        let localRecipeLoader = LocalRecipeLoader(store: swiftDataStore)
        let remoteRecipeLoader = RemoteRecipeLoader(client: URLSessionHTTPClient(), url: url)
        let localImageDataCache = LocalRecipeImageDataLoader(store: swiftDataStore)
        
        return (localRecipeLoader, remoteRecipeLoader, localImageDataCache)
    }
    
    static private func createModelContainer() throws -> ModelContainer {
        do {
            return try ModelContainer(for: SwiftDataLocalRecipe.self, configurations: ModelConfiguration(isStoredInMemoryOnly: false))
        } catch {
            throw CompositionError.badModelContainer
        }
    }
    
    static private func createRecipeUrl() throws -> URL {
        guard let url = URL(string: urlString) else {
            throw CompositionError.badURL
        }
        return url
    }
    
    func retryComposition() {
        self.compositionResult = Self.composeRecipeListView()
    }
}

