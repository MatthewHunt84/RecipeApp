//
//  FetchRecipeTests.swift
//  FetchRecipeTests
//
//  Created by Matt Hunt on 2/9/25.
//

import Testing
import Foundation

struct RemoteRecipeLoader {
    let client: HTTPClient
    func load(from url: URL) {
        client.requestedURL = url
    }
}

class HTTPClient {
    var requestedURL: URL?
}

struct FetchRecipeTests {

    @Test func initDoesNotRequestData() {
        let client = HTTPClient()
        _ = RemoteRecipeLoader(client: client)

        #expect(client.requestedURL == nil)
    }
    
    @Test func loadRequestsDataFromURL() throws {
        let url = try #require(URL(string:"https://test-url.com"))
        let client = HTTPClient()
        let sut = RemoteRecipeLoader(client: client)
        
        sut.load(from: url)
        
        #expect(client.requestedURL == url)
    }
}
