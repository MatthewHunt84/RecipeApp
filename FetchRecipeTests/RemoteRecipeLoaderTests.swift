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
    let url: URL
    
    func load() {
        client.data(from: url)
    }
}

protocol HTTPClient {
    func data(from url: URL)
}

class HTTPClientSpy: HTTPClient {
    
    var lastRequestedURL: URL?
    
    func data(from url: URL) {
        lastRequestedURL = url
    }
}

struct FetchRecipeTests {

    @Test func initDoesNotRequestData() throws {
        let client = HTTPClientSpy()
        let url = try #require(URL(string:"https://test-url.com"))
        _ = RemoteRecipeLoader(client: client, url: url)

        #expect(client.lastRequestedURL == nil)
    }
    
    @Test func loadRequestsDataFromURL() throws {
        let url = try #require(URL(string:"https://test-url.com"))
        let client = HTTPClientSpy()
        let sut = RemoteRecipeLoader(client: client, url: url)
        
        sut.load()
        
        #expect(client.lastRequestedURL == url)
    }
}
