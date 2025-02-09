//
//  FetchRecipeTests.swift
//  FetchRecipeTests
//
//  Created by Matt Hunt on 2/9/25.
//

import Testing
import Foundation

struct RemoteRecipeLoader {
    
}

class HTTPClient {
    var requestedURL: URL?
}

struct FetchRecipeTests {

    @Test func initDoesNotRequestData() async throws {
        let client = HTTPClient()
        _ = RemoteRecipeLoader()

        #expect(client.requestedURL == nil)
    }
}
