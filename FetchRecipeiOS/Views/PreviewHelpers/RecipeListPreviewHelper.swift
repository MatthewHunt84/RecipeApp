//
//  RecipeListPreviewHelper.swift
//  FetchRecipe
//
//  Created by Matt Hunt on 3/17/25.
//

import Foundation

struct RecipeListPreviewHelper {
    
    static func getMockRecipes() async -> [Recipe] {
        (0...10).map { expectedRecipe(at: $0) }
    }
    
    static func expectedRecipe(at index: Int) -> Recipe {
        Recipe(cuisine: cuisine(at: index),
               name: name(at: index),
               photoUrlLarge: photoURLLarge(at: index),
               photoUrlSmall: photoURLSmall(at: index),
               id: uuid(at: index),
               sourceUrl: sourceURL(at: index),
               youtubeUrl: youtubeURL(at: index),
               photoUrlSmallImageData: nil)
    }
    
    static func cuisine(at index: Int) -> String {
        let cuisines = ["Malaysian", "British", "British", "British", "American", "British", "Canadian", "British", "British", "Italian", "Canadian"]
        return cuisines[index]
    }
    
    static func name(at index: Int) -> String {
        let names = ["Apam Balik", "Apple & Blackberry Crumble", "Apple Frangipan Tart", "Bakewell Tart", "Banana Pancakes", "Battenberg Cake", "BeaverTails", "Blackberry Fool", "Bread and Butter Pudding", "Budino Di Ricotta", "Canadian Butter Tarts"]
        return names[index]
    }
    
    static func photoURLLarge(at index: Int) -> String? {
        let photos = ["https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/large.jpg", "https://d3jbb8n5wk0qxi.cloudfront.net/photos/535dfe4e-5d61-4db6-ba8f-7a27b1214f5d/large.jpg", "https://d3jbb8n5wk0qxi.cloudfront.net/photos/7276e9f9-02a2-47a0-8d70-d91bdb149e9e/large.jpg", "https://d3jbb8n5wk0qxi.cloudfront.net/photos/dd936646-8100-4a1c-b5ce-5f97adf30a42/large.jpg", "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b6efe075-6982-4579-b8cf-013d2d1a461b/large.jpg", "https://d3jbb8n5wk0qxi.cloudfront.net/photos/ec1b84b1-2729-4547-99db-5e0b625c0356/large.jpg", "https://d3jbb8n5wk0qxi.cloudfront.net/photos/3b33a385-3e55-4ea5-9d98-13e78f840299/large.jpg", "https://d3jbb8n5wk0qxi.cloudfront.net/photos/ff52841a-df5b-498c-b2ae-1d2e09ea658d/large.jpg", "https://d3jbb8n5wk0qxi.cloudfront.net/photos/10818213-3c03-47ae-a7b1-230baa981226/large.jpg", "https://d3jbb8n5wk0qxi.cloudfront.net/photos/2cac06b3-002e-4df7-bb08-e15bbc7e552d/large.jpg", "https://d3jbb8n5wk0qxi.cloudfront.net/photos/f18384e7-3da7-4714-8f09-bbfa0d2c8913/large.jpg"]
        return photos[index]
    }
    
    static func photoURLSmall(at index: Int) -> String? {
        let photos = ["https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/small.jpg", "https://d3jbb8n5wk0qxi.cloudfront.net/photos/535dfe4e-5d61-4db6-ba8f-7a27b1214f5d/small.jpg", "https://d3jbb8n5wk0qxi.cloudfront.net/photos/7276e9f9-02a2-47a0-8d70-d91bdb149e9e/small.jpg", "https://d3jbb8n5wk0qxi.cloudfront.net/photos/dd936646-8100-4a1c-b5ce-5f97adf30a42/small.jpg", "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b6efe075-6982-4579-b8cf-013d2d1a461b/small.jpg", "https://d3jbb8n5wk0qxi.cloudfront.net/photos/ec1b84b1-2729-4547-99db-5e0b625c0356/small.jpg", "https://d3jbb8n5wk0qxi.cloudfront.net/photos/3b33a385-3e55-4ea5-9d98-13e78f840299/small.jpg", "https://d3jbb8n5wk0qxi.cloudfront.net/photos/ff52841a-df5b-498c-b2ae-1d2e09ea658d/small.jpg", "https://d3jbb8n5wk0qxi.cloudfront.net/photos/10818213-3c03-47ae-a7b1-230baa981226/small.jpg", "https://d3jbb8n5wk0qxi.cloudfront.net/photos/2cac06b3-002e-4df7-bb08-e15bbc7e552d/small.jpg", "https://d3jbb8n5wk0qxi.cloudfront.net/photos/f18384e7-3da7-4714-8f09-bbfa0d2c8913/small.jpg"]
        return photos[index]
    }
    
    static func uuid(at index: Int) -> String {
        let uuids = ["0c6ca6e7-e32a-4053-b824-1dbf749910d8", "599344f4-3c5c-4cca-b914-2210e3b3312f", "74f6d4eb-da50-4901-94d1-deae2d8af1d1", "eed6005f-f8c8-451f-98d0-4088e2b40eb6", "f8b20884-1e54-4e72-a417-dabbc8d91f12", "891a474e-91cd-4996-865e-02ac5facafe3", "b5db2c09-411e-4bdf-9a75-a194dcde311b", "8938f16a-954c-4d65-953f-fa069f3f1b0d", "02a80f95-09d6-430c-a9da-332584229d6f", "563dbb27-5323-443c-b30c-c221ae598568", "39ad8233-c470-4394-b65f-2a6c3218b935"]
        return uuids[index]
    }
    
    static func sourceURL(at index: Int) -> String? {
        let sourceURLs = ["https://www.nyonyacooking.com/recipes/apam-balik~SJ5WuvsDf9WQ", "https://www.bbcgoodfood.com/recipes/778642/apple-and-blackberry-crumble", nil, nil, "https://www.bbcgoodfood.com/recipes/banana-pancakes", "https://www.bbcgoodfood.com/recipes/1120657/battenberg-cake", "https://www.tastemade.com/videos/beavertails", "https://www.bbc.co.uk/food/recipes/blackberry_fool_with_11859", "https://cooking.nytimes.com/recipes/1018529-coq-au-vin", "https://thehappyfoodie.co.uk/recipes/ricotta-cake-budino-di-ricotta", "https://www.bbcgoodfood.com/recipes/1837/canadian-butter-tarts"]
        return sourceURLs[index]
    }
    
    static func youtubeURL(at index: Int) -> String? {
        let youtubeURLs = ["https://www.youtube.com/watch?v=6R8ffRRJcrg", nil, "https://www.youtube.com/watch?v=rp8Slv4INLk", "https://www.youtube.com/watch?v=1ahpSTf_Pvk", "https://www.youtube.com/watch?v=kSKtb2Sv-_U", "https://www.youtube.com/watch?v=aB41Q7kDZQ0", nil, "https://www.youtube.com/watch?v=kniRGjDLFrQ", "https://www.youtube.com/watch?v=Vz5W1-BmOE4", "https://www.youtube.com/watch?v=6dzd6Ra6sb4", "https://www.youtube.com/watch?v=WUpaOGghOdo"]
        return youtubeURLs[index]
    }
    
    static func cacheMockData(data: Data, url: URL) async -> Void {
        return
    }
    
    static func mockData() async -> Data {
        "".data(using: .utf8)!
    }
    
    static func mockRecipeViewFactory(for recipe: Recipe) -> RecipeView {
        RecipeView(recipe: recipe, cacheImageData: cacheMockData)
    }
    
    static func mockRecipeListViewModel() -> RecipeListView.ViewModel {
        RecipeListView.ViewModel(localRecipeLoader: makeDummyLocalRecipeLoader(),
                                 remoteRecipeLoader: makeDummyRemoteRecipeLoader(),
                                 localImageDataCache: makeDummyLocalRecipeImageDataLoader())
    }
    
    static func makeDummyLocalRecipeLoader() -> LocalRecipeLoader {
        return LocalRecipeLoader(store: MockRecipeStore())
    }
    
    static func makeDummyRemoteRecipeLoader() -> RemoteRecipeLoader {
        return RemoteRecipeLoader(client: MockHTTPClient(), url: URL(string: "http://any-url.com")!)
    }
    
    static func makeDummyLocalRecipeImageDataLoader() -> LocalRecipeImageDataLoader {
        return LocalRecipeImageDataLoader(store: MockRecipeImageDataStore())
    }
    
    static func makeDummyHTTPUrlResponse() -> HTTPURLResponse {
        let dummyUrl = URL(string: "http://any-url.com")!
        return HTTPURLResponse(url: dummyUrl, statusCode: 123, httpVersion: nil, headerFields: nil)!
    }
    
    struct MockRecipeStore: RecipeStore {
        func deleteCachedRecipes() async throws {}
        func insertRecipes(_ recipes: [LocalRecipe]) async throws {}
        func retrieveRecipes() async throws -> [LocalRecipe] {
            await getMockRecipes().mapToLocalRecipe()
        }
    }
    
    struct MockRecipeImageDataStore: RecipeImageDataStore {
        func insert(_ data: Data, for url: URL) async throws { }
        
        func retrieveData(for url: URL) async throws -> Data? {
            return nil
        }
    }
    
    
    struct MockHTTPClient: HTTPClient {
        func data(from url: URL) async throws -> (Data, URLResponse) {
            return ("".data(using: .utf8)!, makeDummyHTTPUrlResponse())
        }
        
        
    }
}
