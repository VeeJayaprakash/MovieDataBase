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
    case loaded([Movie])
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

    private let repository: MovieRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()

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
            return
        }

        state = .loading

        do {
            let response = try await repository.searchMovies(query: trimmedQuery, page: 1)
            if response.results.isEmpty {
                state = .empty
            } else {
                state = .loaded(response.results)
            }
        } catch {
            state = .error("Search failed. Please try again.")
        }
    }
}
