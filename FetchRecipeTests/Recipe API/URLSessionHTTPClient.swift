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
        
        do {
            let _ = try await completeWithResult(.failure(expectedError))
        } catch let error as NSError {
            #expect(error.domain == expectedError.domain)
            #expect(error.code == expectedError.code)
        }
    }
    
    @Test func testDataFromURLPerformsRequestWithExpectedURL() async throws {
        let url = try #require(URL(string: "http://specific-test-url.com"))
        let data = anyData()
        let response = URLResponse()
        
        let _ = try await completeWithResult(.success((data, response)), from: url)
        
        #expect(URLProtocolStub.requests.last?.url == url)
        #expect(URLProtocolStub.requests.last?.httpMethod == "GET")
    }
    
    
    @Test func testDataFromURLSucceedsWithValidHTTPURLResponse() async throws {
        let expectedData = anyData()
        let expectedHTTPURLResponse = HTTPURLResponse()
        
        let (data, response) = try await completeWithResult(.success((expectedData, expectedHTTPURLResponse)))
        
        let httpResponse = try #require(response as? HTTPURLResponse)
        #expect(httpResponse.url == expectedHTTPURLResponse.url)
        #expect(httpResponse.statusCode == expectedHTTPURLResponse.statusCode)
        #expect(data == expectedData)
    }
        
    // MARK: Helpers
    
    func makeSUT() -> HTTPClient {
        return URLSessionHTTPClient()
    }
    
    func anyURL() -> URL {
        return try! #require(URL(string: "http://any-url.com"))
    }
    
    func anyData() -> Data {
        return Data("data".utf8)
    }
    
    func completeWithResult(_ result: Result<(Data, URLResponse), Error>, from url: URL? = nil) async throws -> (Data, URLResponse) {
        switch result {
        case .success(let (data, response)):
            URLProtocolStub.stub(data: data, response: response, error: nil)
        case .failure(let error):
            URLProtocolStub.stub(data: nil, response: nil, error: error)
        }
        
        let sut = makeSUT()
        return try await sut.data(from: url ?? anyURL())
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
