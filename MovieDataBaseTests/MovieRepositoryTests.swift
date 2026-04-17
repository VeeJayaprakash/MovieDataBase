//
//  MovieRepositoryTests.swift
//  MovieDataBaseTests
//
//  Created by Vijendran  on 4/15/26.
//

import XCTest
@testable import MovieDataBase

final class MovieRepositoryTests: XCTestCase {

    var sut: MovieRepository!
    var mockClient: MockNetworkClient!

    override func setUp() {
        super.setUp()
        mockClient = MockNetworkClient()
        sut = MovieRepository(client: mockClient)
    }

    override func tearDown() {
        sut = nil
        mockClient = nil
        super.tearDown()
    }

    // MARK: - Fetch Popular Movies

    func test_fetchPopularMovies_createsCorrectEndpoint() async throws {
        // Given
        let expectedResponse = MovieListResponse(page: 1, results: [], totalPages: 1, totalResults: 0)
        mockClient.result = .success(expectedResponse)

        // When
        _ = try await sut.fetchPopularMovies(page: 1)

        // Then
        XCTAssertEqual(mockClient.capturedEndpoint?.path, "/3/discover/movie")
        XCTAssertEqual(mockClient.capturedEndpoint?.method, .get)
        XCTAssertEqual(mockClient.capturedEndpoint?.queryItems?.count, 2)
        XCTAssertTrue(mockClient.capturedEndpoint?.queryItems?.contains(URLQueryItem(name: "page", value: "1")) ?? false)
        XCTAssertTrue(mockClient.capturedEndpoint?.queryItems?.contains(URLQueryItem(name: "sort_by", value: "popularity.desc")) ?? false)
    }

    func test_fetchPopularMovies_returnsResponse() async throws {
        // Given
        let expectedMovies = [
            Movie(id: 1, adult: false, backdropPath: nil, genreIds: [], originalLanguage: "en",
                  originalTitle: "Test", overview: "", popularity: 0, posterPath: nil,
                  releaseDate: "2023-01-01", title: "Test", video: false, voteAverage: 7.0, voteCount: 100)
        ]
        let expectedResponse = MovieListResponse(page: 1, results: expectedMovies, totalPages: 1, totalResults: 1)
        mockClient.result = .success(expectedResponse)

        // When
        let response = try await sut.fetchPopularMovies(page: 1)

        // Then
        XCTAssertEqual(response.results.count, 1)
        XCTAssertEqual(response.results[0].id, 1)
    }

    func test_fetchPopularMovies_throwsError() async {
        // Given
        mockClient.result = .failure(NetworkError.unauthorized)

        // When/Then
        do {
            _ = try await sut.fetchPopularMovies(page: 1)
            XCTFail("Expected error")
        } catch {
            XCTAssertTrue(error is NetworkError)
        }
    }

    // MARK: - Search Movies

    func test_searchMovies_createsCorrectEndpoint() async throws {
        // Given
        let expectedResponse = MovieListResponse(page: 1, results: [], totalPages: 1, totalResults: 0)
        mockClient.result = .success(expectedResponse)

        // When
        _ = try await sut.searchMovies(query: "test query", page: 2)

        // Then
        XCTAssertEqual(mockClient.capturedEndpoint?.path, "/3/search/movie")
        XCTAssertEqual(mockClient.capturedEndpoint?.method, .get)
        XCTAssertEqual(mockClient.capturedEndpoint?.queryItems?.count, 2)
        XCTAssertTrue(mockClient.capturedEndpoint?.queryItems?.contains(URLQueryItem(name: "query", value: "test query")) ?? false)
        XCTAssertTrue(mockClient.capturedEndpoint?.queryItems?.contains(URLQueryItem(name: "page", value: "2")) ?? false)
    }

    func test_searchMovies_returnsResponse() async throws {
        // Given
        let expectedMovies = [
            Movie(id: 5, adult: false, backdropPath: nil, genreIds: [], originalLanguage: "en",
                  originalTitle: "Search Result", overview: "", popularity: 0, posterPath: nil,
                  releaseDate: "2023-01-01", title: "Search Result", video: false, voteAverage: 8.0, voteCount: 50)
        ]
        let expectedResponse = MovieListResponse(page: 1, results: expectedMovies, totalPages: 1, totalResults: 1)
        mockClient.result = .success(expectedResponse)

        // When
        let response = try await sut.searchMovies(query: "test", page: 1)

        // Then
        XCTAssertEqual(response.results.count, 1)
        XCTAssertEqual(response.results[0].id, 5)
    }
}

// MARK: - Mock Network Client

final class MockNetworkClient: NetworkClient {
    var result: Result<Any, Error>?
    var capturedEndpoint: Endpoint?

    init() {
        super.init(baseURL: "https://test.com")
    }

    override func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        capturedEndpoint = endpoint

        guard let result = result else {
            fatalError("result not set")
        }

        switch result {
        case .success(let value):
            guard let typedValue = value as? T else {
                fatalError("Type mismatch: expected \(T.self), got \(type(of: value))")
            }
            return typedValue
        case .failure(let error):
            throw error
        }
    }
}
