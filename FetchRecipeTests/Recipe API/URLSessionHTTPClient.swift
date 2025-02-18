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

@Suite(.serialized)
class URLSessionHTTPClientTests {
    
    init() { URLProtocolStub.startInterceptingRequests() }
    deinit { URLProtocolStub.stopInterceptingRequests() }
    
    @Test func testDataFromURLFailsOnRequestError() async throws {

        let errorIn = NSError(domain: "URL Request failed", code: 0)
        let sut = makeSUT()
        URLProtocolStub.stub(data: nil, response: nil, error: errorIn)
        
        do {
            let _ = try await sut.data(from: anyURL())
        } catch {
            let nsError = error as NSError
            #expect(nsError.domain == errorIn.domain)
            #expect(nsError.code == errorIn.code)
        }
    }
    
    @Test func testDataFromURLPerformsRequestWithExpectedURL() async throws {
        let url = try #require(URL(string: "http://specific-test-url.com"))
        let data = Data("data".utf8)
        let response = URLResponse()
        let sut = makeSUT()
        URLProtocolStub.stub(data: data, response: response, error: nil)
        
        let _ = try await sut.data(from: url)
        
        #expect(URLProtocolStub.requests.last?.url == url)
        #expect(URLProtocolStub.requests.last?.httpMethod == "GET")
    }
    
    // MARK: Helpers
    
    func makeSUT() -> HTTPClient {
        return URLSessionHTTPClient()
    }
    
    func anyURL() -> URL {
        return try! #require(URL(string: "http://any-url.com"))
    }
}



private class URLProtocolStub: URLProtocol {
    
    private struct Stub {
        let data: Data?
        let response: URLResponse?
        let error: Error?
    }

    private static var stubs: [Stub] = []
    static var requests: [URLRequest] = []
    
    static func stub(data: Data?, response: URLResponse?, error: Error?) {
        stubs.append(Stub(data: data, response: response, error: error))
    }
    
    static func startInterceptingRequests() {
        URLProtocol.registerClass(URLProtocolStub.self)
    }
    
    static func stopInterceptingRequests() {
        URLProtocol.unregisterClass(URLProtocolStub.self)
        stubs = []
        requests = []
    }

    override class func canInit(with request: URLRequest) -> Bool {
        requests.append(request)
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let stub = URLProtocolStub.stubs.first else { return }
        
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
