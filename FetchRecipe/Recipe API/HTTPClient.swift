//
//  HTTPClient.swift
//  FetchRecipe
//
//  Created by Matt Hunt on 2/17/25.
//

import Foundation

public protocol HTTPClient {
    func data(from url: URL) async throws -> (Data, URLResponse)
}
