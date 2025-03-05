//
//  SwiftDataLocalRecipe.swift
//  FetchRecipe
//
//  Created by Matt Hunt on 3/5/25.
//

import SwiftData
import Foundation

@Model
public class SwiftDataLocalRecipe {
    var cuisine: String
    var name: String
    var photoUrlLarge: String?
    var photoUrlSmall: String?
    @Attribute(.unique) var uuid: String
    var sourceUrl: String?
    var youtubeUrl: String?
    
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
            youtubeUrl: youtubeUrl)
    }
    
    public init(_ localRecipe: LocalRecipe) {
        self.cuisine = localRecipe.cuisine
        self.name = localRecipe.name
        self.photoUrlLarge = localRecipe.photoUrlLarge
        self.photoUrlSmall = localRecipe.photoUrlSmall
        self.uuid = localRecipe.uuid
        self.sourceUrl = localRecipe.sourceUrl
        self.youtubeUrl = localRecipe.youtubeUrl
    }
}
