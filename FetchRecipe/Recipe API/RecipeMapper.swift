//
//  RecipeMapper.swift
//  FetchRecipe
//
//  Created by Matt Hunt on 2/17/25.
//

import Foundation

struct RemoteRecipe: Codable, Equatable {
    let cuisine: String
    let name: String
    let photoUrlLarge: String?
    let photoUrlSmall: String?
    let uuid: String
    let sourceUrl: String?
    let youtubeUrl: String?
    
    init(cuisine: String, name: String, photoUrlLarge: String?, photoUrlSmall: String?, uuid: String, sourceUrl: String?, youtubeUrl: String?) {
        self.cuisine = cuisine
        self.name = name
        self.photoUrlLarge = photoUrlLarge
        self.photoUrlSmall = photoUrlSmall
        self.uuid = uuid
        self.sourceUrl = sourceUrl
        self.youtubeUrl = youtubeUrl
    }
}

struct RecipeMapper {
    
    private static let OK_200 = 200
    
    private struct Root: Codable {
        let recipes: [RemoteRecipe]
        
        public init(recipes: [RemoteRecipe]) {
            self.recipes = recipes
        }
    }
    
    static func map(_ data: Data, _ response: URLResponse) throws -> [RemoteRecipe] {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw RemoteRecipeLoader.Error.invalidHTTPResponse
        }
        guard httpResponse.statusCode == OK_200 else {
            throw RemoteRecipeLoader.Error.invalidStatusCode
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        guard let root = try? decoder.decode(Root.self, from: data) else {
            throw RemoteRecipeLoader.Error.decodingError
        }
        
        return root.recipes
    }
}



    


