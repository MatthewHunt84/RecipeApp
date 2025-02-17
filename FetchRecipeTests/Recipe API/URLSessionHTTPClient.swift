//
//  URLSessionHTTPClient.swift
//  FetchRecipeTests
//
//  Created by Matt Hunt on 2/17/25.
//

import Foundation
import FetchRecipe
import Testing

struct URLSessionHTTPClient: HTTPClient {

    let session: URLSession = .shared
    
    func data(from url: URL) async throws -> (Data, URLResponse) {
        try await session.data(from: url)
    }
}

struct URLSessionHTTPClientTests {
    
    @Test func testDataFromURLFailsOnRequestError() async throws {
        URLProtocolStub.startInterceptingRequests()
        let url = try #require(URL(string: "http://any-url.com"))
        let errorIn = NSError(domain: "URL Request failed", code: 0)
        URLProtocolStub.stub(url: url, data: nil, response: nil, error: errorIn)
        let sut = URLSessionHTTPClient()
        
        do {
            let _ = try await sut.data(from: url)
        } catch {
            let nsError = error as NSError
            #expect(nsError.domain == errorIn.domain)
            #expect(nsError.code == errorIn.code)
        }
        
        URLProtocolStub.stopInterceptingRequests()
    }
}

private class URLProtocolStub: URLProtocol {
    
    private struct Stub {
        let data: Data?
        let response: URLResponse?
        let error: Error?
    }

    private static var stubs: [URL: Stub] = [:]
    
    static func stub(url: URL, data: Data?, response: URLResponse?, error: Error?) {
        stubs[url] = Stub(data: data, response: response, error: error)
    }
    
    static func startInterceptingRequests() {
        URLProtocol.registerClass(URLProtocolStub.self)
    }
    
    static func stopInterceptingRequests() {
        URLProtocol.unregisterClass(URLProtocolStub.self)
        stubs = [:]
    }

    override class func canInit(with request: URLRequest) -> Bool {
        guard let url = request.url else { return false }
        return stubs[url] != nil
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let url = request.url,
              let stub = URLProtocolStub.stubs[url] else { return }
        
        if let error = stub.error {
            client?.urlProtocol(self, didFailWithError: error)
        }
        
        if let data = stub.data {
            client?.urlProtocol(self, didLoad: data)
        }
        
        if let response = stub.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() { }
}
