//
//  MovieListViewModel.swift
//  MovieDataBase
//
//  Created by Vijendran  on 4/15/26.
//

import Foundation
import Combine

/// View states for the movie list screen.
enum MovieListState {
    case idle
    case loading
    case loaded
    case error(String)
}

/// ViewModel for the Movie List screen.
///
/// Manages fetching popular movies and handling view states.
@MainActor
final class MovieListViewModel: ObservableObject {
    @Published private(set) var state: MovieListState = .idle

    private let repository: MovieRepositoryProtocol
    private(set) var movies:[Movie] = []
    @Published private(set) var showLoadMore:Bool = false

    private var currentPage = 0
    private var totalPages = 1

    init(repository: MovieRepositoryProtocol) {
        self.repository = repository
    }

    /// Fetches popular movies from the repository.
    func fetchMovies() async {
        state = .loading
        currentPage = 0
        totalPages = 1
        movies = []

        do {
            let response = try await repository.fetchPopularMovies(page: 1)
            state = .loaded
            movies = response.results
            currentPage = response.page
            totalPages = response.totalPages
        } catch {
            state = .error("Failed to load movies. Please try again.")
        }
    }
    
    func fetchMoreMovies() async {
        guard !showLoadMore, currentPage < totalPages else { return }

        showLoadMore = true
        do {
            let response = try await repository.fetchPopularMovies(page: currentPage + 1)
            movies.append(contentsOf: response.results)
            currentPage = response.page
            totalPages = response.totalPages
        } catch {
            // Silent failure for pagination - don't disrupt already loaded content
        }
        showLoadMore = false
    }
}
