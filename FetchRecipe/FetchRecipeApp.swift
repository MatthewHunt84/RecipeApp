//
//  FetchRecipeApp.swift
//  FetchRecipe
//
//  Created by Matt Hunt on 2/7/25.
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
                ErrorView(error: error, retryAction: compositionRoot.retryComposition)
            }
        }
    }
}

@Observable
class CompositionRoot {
    
    enum CompositionError: Swift.Error {
        case badURL
        case badModelContainer
    }
    
    private static var urlString = "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json"
    private(set) var compositionResult: Result<RecipeListView, Error>
    
    init() {
        self.compositionResult = Self.composeRecipeListView()
    }
    
    func retryComposition() {
        self.compositionResult = Self.composeRecipeListView()
    }
    
    static func composeRecipeListView() -> Result<RecipeListView, Error> {
        do {
            let (localRecipeLoader, remoteRecipeLoader) = try getRecipeListViewDependencies()
            
            func getRecipes() async -> [Recipe] {
                do {
                    let recipes = try await remoteRecipeLoader.load()
                    try await localRecipeLoader.save(recipes)
                    return recipes
                } catch {
                    // Handle errors
                    return []
                }
            }
            return .success(RecipeListView(errorMessage: nil, getRecipes: getRecipes))
        } catch {
            return .failure(error)
        }
    }
    
    static private func getRecipeListViewDependencies() throws -> (LocalRecipeLoader, RemoteRecipeLoader) {
        let url = try createRecipeUrl()
        let modelContainer = try createModelContainer()
        let swiftDataStore = SwiftDataStore(modelContainer: modelContainer)
        let localRecipeLoader = LocalRecipeLoader(store: swiftDataStore)
        let remoteRecipeLoader = RemoteRecipeLoader(client: URLSessionHTTPClient(), url: url)
        
        return (localRecipeLoader, remoteRecipeLoader)
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
}
