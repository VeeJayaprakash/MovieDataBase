//
//  SearchViewModel.swift
//  MovieDataBase
//
//  Created by Vijendran  on 4/15/26.
//

import Foundation
import Combine

/// View states for the search screen.
enum SearchState {
    case idle
    case loading
    case loaded
    case empty
    case error(String)
}

/// ViewModel for the Search screen.
///
/// Manages debounced search input and result states.
@MainActor
final class SearchViewModel: ObservableObject {
    @Published var query: String = ""
    @Published private(set) var state: SearchState = .idle
    @Published private(set) var movies: [Movie] = []
    @Published private(set) var showLoadMore: Bool = false

    private let repository: MovieRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()

    private var currentPage = 0
    private var totalPages = 1
    private var currentQuery = ""

    init(repository: MovieRepositoryProtocol) {
        self.repository = repository
        setupDebounce()
    }

    private func setupDebounce() {
        $query
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                guard let self else { return }
                Task { await self.performSearch(query: query) }
            }
            .store(in: &cancellables)
    }

    private func performSearch(query: String) async {
        let trimmedQuery = query.trimmingCharacters(in: .whitespaces)

        guard !trimmedQuery.isEmpty else {
            state = .idle
            movies = []
            currentPage = 0
            totalPages = 1
            currentQuery = ""
            return
        }

        state = .loading
        currentPage = 0
        totalPages = 1
        movies = []
        currentQuery = trimmedQuery

        do {
            let response = try await repository.searchMovies(query: trimmedQuery, page: 1)
            if response.results.isEmpty {
                state = .empty
            } else {
                state = .loaded
                movies = response.results
                currentPage = response.page
                totalPages = response.totalPages
            }
        } catch {
            state = .error("Search failed. Please try again.")
        }
    }

    func fetchMoreResults() async {
        guard !showLoadMore, currentPage < totalPages, !currentQuery.isEmpty else { return }

        showLoadMore = true
        do {
            let response = try await repository.searchMovies(query: currentQuery, page: currentPage + 1)
            movies.append(contentsOf: response.results)
            currentPage = response.page
            totalPages = response.totalPages
        } catch {
            // Silent failure for pagination - don't disrupt already loaded content
        }
        showLoadMore = false
    }
}
