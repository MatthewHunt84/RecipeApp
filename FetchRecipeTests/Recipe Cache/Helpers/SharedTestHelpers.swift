//
//  SharedTestHelpers.swift
//  FetchRecipe
//
//  Created by Matt Hunt on 3/11/25.
//
import Foundation
import FetchRecipe
import Testing

func makeUniqueLocalRecipe() -> LocalRecipe {
    LocalRecipe(cuisine: "any",
           name: "any",
           photoUrlLarge: nil,
           photoUrlSmall: nil,
           uuid: UUID().uuidString,
           sourceUrl: nil,
           youtubeUrl: nil)
}

func anyURL() throws -> URL {
    return try #require(URL(string: "http://any-url.com"))
}
