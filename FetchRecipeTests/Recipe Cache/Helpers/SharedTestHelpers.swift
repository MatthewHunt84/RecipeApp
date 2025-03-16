//
//  SharedTestHelpers.swift
//  FetchRecipe
//
//  Created by Matt Hunt on 3/11/25.
//
import Foundation
import FetchRecipe


func makeUniqueLocalRecipe() -> LocalRecipe {
    LocalRecipe(cuisine: "any",
           name: "any",
           photoUrlLarge: nil,
           photoUrlSmall: nil,
           uuid: UUID().uuidString,
           sourceUrl: nil,
           youtubeUrl: nil)
}
