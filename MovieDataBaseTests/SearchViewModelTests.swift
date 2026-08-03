//
//  SearchViewModelTests.swift
//  MovieDataBaseTests
//
//  Created by Vijendran  on 4/15/26.
//

import XCTest
import Combine
@testable import MovieDataBase

@MainActor
final class SearchViewModelTests: XCTestCase {

    var sut: SearchViewModel!
    var mockRepository: MockMovieRepositoryForTests!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockRepository = MockMovieRepositoryForTests()
        sut = SearchViewModel(repository: mockRepository)
        cancellables = []
    }

    override func tearDown() {
        cancellables = nil
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

    func test_init_queryIsEmpty() {
        // Then
        XCTAssertEqual(sut.query, "")
    }

    // MARK: - Empty Query

    func test_emptyQuery_stateRemainsIdle() async {
        // Given
        sut.query = ""

        // Wait for debounce
        try? await Task.sleep(nanoseconds: 400_000_000) // 400ms

        // Then
        if case .idle = sut.state {
            // Success
        } else {
            XCTFail("Expected idle state, got \(sut.state)")
        }
    }

    func test_whitespaceQuery_stateRemainsIdle() async {
        // Given
        sut.query = "   "

        // Wait for debounce
        try? await Task.sleep(nanoseconds: 400_000_000) // 400ms

        // Then
        if case .idle = sut.state {
            // Success
        } else {
            XCTFail("Expected idle state, got \(sut.state)")
        }
    }

    // MARK: - Search Success

    func test_search_success_transitionsToLoadedState() async {
        // Given
        let expectedMovies = [
            Movie(id: 1, adult: false, backdropPath: nil, genreIds: [], originalLanguage: "en",
                  originalTitle: "Movie 1", overview: "", popularity: 0, posterPath: nil,
                  releaseDate: "2023-01-01", title: "Movie 1", video: false, voteAverage: 7.5, voteCount: 100)
        ]
        let response = MovieListResponse(page: 1, results: expectedMovies, totalPages: 1, totalResults: 1)
        mockRepository.searchMoviesResult = .success(response)

        // When
        sut.query = "test"

        // Wait for debounce + network call
        try? await Task.sleep(nanoseconds: 500_000_000) // 500ms

        // Then
        if case .loaded = sut.state {
            XCTAssertEqual(sut.movies.count, 1)
            XCTAssertEqual(sut.movies[0].id, 1)
        } else {
            XCTFail("Expected loaded state, got \(sut.state)")
        }
    }

    // MARK: - Empty Results

    func test_search_emptyResults_transitionsToEmptyState() async {
        // Given
        let response = MovieListResponse(page: 1, results: [], totalPages: 1, totalResults: 0)
        mockRepository.searchMoviesResult = .success(response)

        // When
        sut.query = "xyz123"

        // Wait for debounce + network call
        try? await Task.sleep(nanoseconds: 500_000_000) // 500ms

        // Then
        if case .empty = sut.state {
            // Success
        } else {
            XCTFail("Expected empty state, got \(sut.state)")
        }
    }

    // MARK: - Search Error

    func test_search_error_transitionsToErrorState() async {
        // Given
        mockRepository.searchMoviesResult = .failure(NetworkError.unauthorized)

        // When
        sut.query = "test"

        // Wait for debounce + network call
        try? await Task.sleep(nanoseconds: 500_000_000) // 500ms

        // Then
        if case .error(let message) = sut.state {
            XCTAssertTrue(message.contains("Search failed"))
        } else {
            XCTFail("Expected error state, got \(sut.state)")
        }
    }

    // MARK: - Debounce Behavior

    func test_rapidQueryChanges_debouncesRequests() async {
        // Given
        mockRepository.searchMoviesResult = .success(
            MovieListResponse(page: 1, results: [], totalPages: 1, totalResults: 0)
        )

        // When - rapid changes
        sut.query = "a"
        try? await Task.sleep(nanoseconds: 50_000_000) // 50ms
        sut.query = "ab"
        try? await Task.sleep(nanoseconds: 50_000_000) // 50ms
        sut.query = "abc"

        // Wait for debounce
        try? await Task.sleep(nanoseconds: 500_000_000) // 500ms

        // Then - only last query should trigger request
        XCTAssertEqual(mockRepository.searchMoviesCallCount, 1)
    }
}
