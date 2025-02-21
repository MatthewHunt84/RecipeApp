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

        let expectedError = NSError(domain: "URL Request failed", code: 0)
        let sut = makeSUT()
        URLProtocolStub.stub(data: nil, response: nil, error: expectedError)
        
        do {
            let _ = try await sut.data(from: anyURL())
        } catch let error as NSError {
            #expect(error.domain == expectedError.domain)
            #expect(error.code == expectedError.code)
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
    
    @Test func dataFromURLFailsWithNilValues() async throws {
        let sut = makeSUT()
        URLProtocolStub.stub(data: nil, response: nil, error: nil)
        
        do {
            let _ = try await sut.data(from: anyURL())
        } catch let error as NSError {
            #expect(error.domain == "All values nil")
        }
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
        if stub.data == nil, stub.response == nil, stub.error == nil {
            client?.urlProtocol(self, didFailWithError: NSError(domain: "All values nil", code: 0))
        }
        
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
