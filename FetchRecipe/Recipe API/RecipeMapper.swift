//
//  RecipeMapper.swift
//  FetchRecipe
//
//  Created by Matt Hunt on 2/17/25.
//

import Foundation

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



    


