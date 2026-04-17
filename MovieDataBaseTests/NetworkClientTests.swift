//
//  NetworkClientTests.swift
//  MovieDataBaseTests
//
//  Created by Vijendran  on 4/15/26.
//

import XCTest
@testable import MovieDataBase

final class NetworkClientTests: XCTestCase {

    var sut: NetworkClient!

    override func setUp() {
        super.setUp()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        sut = NetworkClient(baseURL: "https://api.test.com", session: session)
    }

    override func tearDown() {
        sut = nil
        MockURLProtocol.requestHandler = nil
        super.tearDown()
    }

    // MARK: - Success Cases

    func test_request_successfulResponse_decodesData() async throws {
        // Given
        let expectedMovie = TestMovie(id: 1, title: "Test Movie")
        let data = try JSONEncoder().encode(expectedMovie)

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, data)
        }

        let endpoint = Endpoint(path: "/test")

        // When
        let result: TestMovie = try await sut.request(endpoint)

        // Then
        XCTAssertEqual(result.id, expectedMovie.id)
        XCTAssertEqual(result.title, expectedMovie.title)
    }

    // MARK: - Error Cases

    func test_request_invalidURL_throwsBadURLError() async {
        // Given
        let endpoint = Endpoint(path: "invalid url with spaces")

        // When/Then
        do {
            let _: TestMovie = try await sut.request(endpoint)
            XCTFail("Expected badURL error")
        } catch let error as NetworkError {
            if case .badURL = error {
                // Success
            } else {
                XCTFail("Expected badURL error, got \(error)")
            }
        } catch {
            XCTFail("Expected NetworkError, got \(error)")
        }
    }

    func test_request_unauthorizedStatus_throwsUnauthorizedError() async {
        // Given
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 401,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }

        let endpoint = Endpoint(path: "/test")

        // When/Then
        do {
            let _: TestMovie = try await sut.request(endpoint)
            XCTFail("Expected unauthorized error")
        } catch let error as NetworkError {
            if case .unauthorized = error {
                // Success
            } else {
                XCTFail("Expected unauthorized error, got \(error)")
            }
        } catch {
            XCTFail("Expected NetworkError, got \(error)")
        }
    }

    func test_request_serverError_throwsServerError() async {
        // Given
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 500,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }

        let endpoint = Endpoint(path: "/test")

        // When/Then
        do {
            let _: TestMovie = try await sut.request(endpoint)
            XCTFail("Expected serverError")
        } catch let error as NetworkError {
            if case .serverError(let statusCode) = error {
                XCTAssertEqual(statusCode, 500)
            } else {
                XCTFail("Expected serverError, got \(error)")
            }
        } catch {
            XCTFail("Expected NetworkError, got \(error)")
        }
    }

    func test_request_invalidJSON_throwsDecodingFailedError() async {
        // Given
        let invalidJSON = "not json".data(using: .utf8)!

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, invalidJSON)
        }

        let endpoint = Endpoint(path: "/test")

        // When/Then
        do {
            let _: TestMovie = try await sut.request(endpoint)
            XCTFail("Expected decodingFailed error")
        } catch let error as NetworkError {
            if case .decodingFailed = error {
                // Success
            } else {
                XCTFail("Expected decodingFailed error, got \(error)")
            }
        } catch {
            XCTFail("Expected NetworkError, got \(error)")
        }
    }

    func test_request_networkFailure_throwsURLError() async {
        // Given
        MockURLProtocol.requestHandler = { request in
            throw URLError(.notConnectedToInternet)
        }

        let endpoint = Endpoint(path: "/test")

        // When/Then
        do {
            let _: TestMovie = try await sut.request(endpoint)
            XCTFail("Expected urlError")
        } catch let error as NetworkError {
            if case .urlError = error {
                // Success
            } else {
                XCTFail("Expected urlError, got \(error)")
            }
        } catch {
            XCTFail("Expected NetworkError, got \(error)")
        }
    }
}

// MARK: - Test Helpers

struct TestMovie: Codable, Equatable {
    let id: Int
    let title: String
}

class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            fatalError("Handler is unavailable")
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
