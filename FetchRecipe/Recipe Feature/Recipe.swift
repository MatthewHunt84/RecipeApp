//
//  Recipe.swift
//  FetchRecipe
//
//  Created by Matt Hunt on 2/9/25.
//

import Foundation

struct Recipe {
    let cuisine: String
    let name: String
    let photoUrlLarge: String?
    let photoUrlSmall: String?
    let uuid: UUID
    let sourceUrl: String?
    let youtubeUrl: String?
}
