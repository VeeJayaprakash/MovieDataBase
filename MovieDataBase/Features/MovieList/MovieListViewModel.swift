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
    case loaded([Movie])
    case error(String)
}

/// ViewModel for the Movie List screen.
///
/// Manages fetching popular movies and handling view states.
@MainActor
final class MovieListViewModel: ObservableObject {
    @Published private(set) var state: MovieListState = .idle

    private let repository: MovieRepositoryProtocol

    init(repository: MovieRepositoryProtocol) {
        self.repository = repository
    }

    /// Fetches popular movies from the repository.
    func fetchMovies() async {
        state = .loading

        do {
            let response = try await repository.fetchPopularMovies(page: 1)
            state = .loaded(response.results)
        } catch {
            state = .error("Failed to load movies. Please try again.")
        }
    }
}
