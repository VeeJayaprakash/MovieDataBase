//
//  MovieListViewModelTests.swift
//  MovieDataBaseTests
//
//  Created by Vijendran  on 4/15/26.
//

import XCTest
@testable import MovieDataBase

@MainActor
final class MovieListViewModelTests: XCTestCase {

    var sut: MovieListViewModel!
    var mockRepository: MockMovieRepositoryForTests!

    override func setUp() {
        super.setUp()
        mockRepository = MockMovieRepositoryForTests()
        sut = MovieListViewModel(repository: mockRepository)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    // MARK: - Initial State

    func test_init_stateIsIdle() {
        // Then
        if case .idle = sut.state {
            // Success
        } else {
            XCTFail("Expected idle state, got \(sut.state)")
        }
    }

    // MARK: - Fetch Movies Success

    func test_fetchMovies_success_transitionsToLoadedState() async {
        // Given
        let expectedMovies = [
            Movie(id: 1, adult: false, backdropPath: nil, genreIds: [], originalLanguage: "en",
                  originalTitle: "Movie 1", overview: "", popularity: 0, posterPath: nil,
                  releaseDate: "2023-01-01", title: "Movie 1", video: false, voteAverage: 7.5, voteCount: 100),
            Movie(id: 2, adult: false, backdropPath: nil, genreIds: [], originalLanguage: "en",
                  originalTitle: "Movie 2", overview: "", popularity: 0, posterPath: nil,
                  releaseDate: "2023-02-01", title: "Movie 2", video: false, voteAverage: 8.0, voteCount: 200)
        ]
        let response = MovieListResponse(page: 1, results: expectedMovies, totalPages: 1, totalResults: 2)
        mockRepository.popularMoviesResult = .success(response)

        // When
        await sut.fetchMovies()

        // Then
        if case .loaded(let movies) = sut.state {
            XCTAssertEqual(movies.count, 2)
            XCTAssertEqual(movies[0].id, 1)
            XCTAssertEqual(movies[1].id, 2)
        } else {
            XCTFail("Expected loaded state, got \(sut.state)")
        }
    }

    func test_fetchMovies_success_passesLoadingState() async {
        // Given
        mockRepository.popularMoviesResult = .success(
            MovieListResponse(page: 1, results: [], totalPages: 1, totalResults: 0)
        )
        mockRepository.delayDuration = 0.1

        // When
        let expectation = XCTestExpectation(description: "Loading state observed")
        Task {
            await sut.fetchMovies()
        }

        // Wait briefly to catch loading state
        try? await Task.sleep(nanoseconds: 50_000_000) // 50ms

        // Then
        if case .loading = sut.state {
            expectation.fulfill()
        }

        await fulfillment(of: [expectation], timeout: 1.0)
    }

    // MARK: - Fetch Movies Error

    func test_fetchMovies_error_transitionsToErrorState() async {
        // Given
        mockRepository.popularMoviesResult = .failure(NetworkError.unauthorized)

        // When
        await sut.fetchMovies()

        // Then
        if case .error(let message) = sut.state {
            XCTAssertTrue(message.contains("Failed to load movies"))
        } else {
            XCTFail("Expected error state, got \(sut.state)")
        }
    }
}

// MARK: - Mock Repository

final class MockMovieRepositoryForTests: MovieRepositoryProtocol {
    var popularMoviesResult: Result<MovieListResponse, Error>?
    var searchMoviesResult: Result<MovieListResponse, Error>?
    var delayDuration: TimeInterval = 0
                                                                                                                                              
    // Call tracking
    var fetchPopularMoviesCallCount = 0
    var searchMoviesCallCount = 0
                                                                                                                                              
    func fetchPopularMovies(page: Int) async throws -> MovieListResponse {
        fetchPopularMoviesCallCount += 1
                                                                                                                                              
        if delayDuration > 0 {
            try? await Task.sleep(nanoseconds: UInt64(delayDuration * 1_000_000_000))
        }
                                                                                                                                              
        guard let result = popularMoviesResult else {
            fatalError("popularMoviesResult not set")
        }
                                                                                                                                              
        switch result {
        case .success(let response):
            return response
        case .failure(let error):
            throw error
        }
    }
                                                                                                                                              
    func searchMovies(query: String, page: Int) async throws -> MovieListResponse {
        searchMoviesCallCount += 1
                                                                                                                                              
        if delayDuration > 0 {
            try? await Task.sleep(nanoseconds: UInt64(delayDuration * 1_000_000_000))
        }
                                                                                                                                              
        guard let result = searchMoviesResult else {
            fatalError("searchMoviesResult not set")
        }
                                                                                                                                              
        switch result {
        case .success(let response):
            return response
        case .failure(let error):
            throw error
        }
    }
}
