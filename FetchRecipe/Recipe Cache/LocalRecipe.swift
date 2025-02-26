//
//  Untitled.swift
//  FetchRecipe
//
//  Created by Matt Hunt on 2/22/25.
//

import Foundation

public struct LocalRecipe: Codable, Equatable {
    public let cuisine: String
    public let name: String
    public let photoUrlLarge: String?
    public let photoUrlSmall: String?
    public let uuid: String
    public let sourceUrl: String?
    public let youtubeUrl: String?
    
    public init(cuisine: String, name: String, photoUrlLarge: String?, photoUrlSmall: String?, uuid: String, sourceUrl: String?, youtubeUrl: String?) {
        self.cuisine = cuisine
        self.name = name
        self.photoUrlLarge = photoUrlLarge
        self.photoUrlSmall = photoUrlSmall
        self.uuid = uuid
        self.sourceUrl = sourceUrl
        self.youtubeUrl = youtubeUrl
    }
}

extension LocalRecipe: Comparable {
    public static func < (lhs: LocalRecipe, rhs: LocalRecipe) -> Bool {
        lhs.uuid < rhs.uuid
    }
}

