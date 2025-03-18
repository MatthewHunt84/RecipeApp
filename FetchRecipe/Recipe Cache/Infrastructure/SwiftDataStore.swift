//
//  SwiftDataStore.swift
//  FetchRecipe
//
//  Created by Matt Hunt on 3/5/25.
//

import Foundation
import SwiftData

@ModelActor
public actor SwiftDataStore: RecipeStore {
    
    public func retrieveRecipes() throws -> [LocalRecipe] {
        let descriptor = FetchDescriptor<SwiftDataLocalRecipe>(sortBy: [SortDescriptor(\SwiftDataLocalRecipe.name)])
        let swiftDataModels: [SwiftDataLocalRecipe] = try modelContext.fetch(descriptor)
        return swiftDataModels.map { $0.local }
    }
    
    public func insertRecipes(_ recipes: [LocalRecipe]) throws {
        try deleteCachedRecipes()
        let swiftDataModels = recipes.map(SwiftDataLocalRecipe.init)
        swiftDataModels.forEach { model in
            modelContext.insert(model)
        }
        try modelContext.save()
    }
    
    public func deleteCachedRecipes() throws {
        try modelContext.delete(model: SwiftDataLocalRecipe.self)
        try modelContext.save()
    }
}

extension SwiftDataStore: RecipeImageDataStore {
    
    public enum Error: Swift.Error {
        case urlNotFound
        case duplicateUrl
    }
    
    public func insert(_ data: Data, for url: URL) throws {
        let urlString = url.absoluteString
        let predicate = #Predicate<SwiftDataLocalRecipe> { recipe in
            recipe.photoUrlSmall == urlString
        }
        let descriptor = FetchDescriptor<SwiftDataLocalRecipe>(predicate: predicate)
        let matchedRecipe = try modelContext.fetch(descriptor)

        guard matchedRecipe.count < 2 else {
            throw Error.duplicateUrl
        }
        if let recipe = matchedRecipe.first {
            recipe.photoUrlSmallImageData = data
            try modelContext.save()
        } else {
            throw Error.urlNotFound
        }
    }
    
    public func retrieveData(for url: URL) throws -> Data? {
        let urlString = url.absoluteString
        let predicate = #Predicate<SwiftDataLocalRecipe> { recipe in
            recipe.photoUrlSmall == urlString
        }
        let descriptor = FetchDescriptor<SwiftDataLocalRecipe>(predicate: predicate)
        let matchedRecipe = try modelContext.fetch(descriptor)
        guard matchedRecipe.count < 2 else {
            throw Error.duplicateUrl
        }
        guard let imageData = matchedRecipe.first?.photoUrlSmallImageData else {
            throw Error.urlNotFound
        }
        return imageData
    }
}

@Model
public class SwiftDataLocalRecipe {
    fileprivate var cuisine: String
    fileprivate var name: String
    fileprivate var photoUrlLarge: String?
    fileprivate var photoUrlSmall: String?
    @Attribute(.unique) fileprivate var uuid: String
    fileprivate var sourceUrl: String?
    fileprivate var youtubeUrl: String?
    fileprivate var photoUrlSmallImageData: Data?
    
    public init(cuisine: String,
         name: String,
         photoUrlLarge: String?,
         photoUrlSmall: String?,
         uuid: String,
         sourceUrl: String?,
         youtubeUrl: String?) {
        self.cuisine = cuisine
        self.name = name
        self.photoUrlLarge = photoUrlLarge
        self.photoUrlSmall = photoUrlSmall
        self.uuid = uuid
        self.sourceUrl = sourceUrl
        self.youtubeUrl = youtubeUrl
    }
    
    public var local: LocalRecipe {
        LocalRecipe(
            cuisine: cuisine,
            name: name,
            photoUrlLarge: photoUrlLarge,
            photoUrlSmall: photoUrlSmall,
            uuid: uuid,
            sourceUrl: sourceUrl,
            youtubeUrl: youtubeUrl,
            photoUrlSmallImageData: photoUrlSmallImageData)
    }
    
    public init(_ localRecipe: LocalRecipe) {
        self.cuisine = localRecipe.cuisine
        self.name = localRecipe.name
        self.photoUrlLarge = localRecipe.photoUrlLarge
        self.photoUrlSmall = localRecipe.photoUrlSmall
        self.uuid = localRecipe.uuid
        self.sourceUrl = localRecipe.sourceUrl
        self.youtubeUrl = localRecipe.youtubeUrl
        self.photoUrlSmallImageData = localRecipe.photoUrlSmallImageData
    }
}
