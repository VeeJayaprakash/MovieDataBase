//
//  SearchView.swift
//  MovieDataBase
//
//  Created by Vijendran  on 4/15/26.
//

import SwiftUI
import Kingfisher

/// Search screen with search bar and results list.
struct SearchView: View {
    @ObservedObject var viewModel: SearchViewModel

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle:
                emptyStateView(message: "Search for movies")

            case .loading:
                ProgressView("Searching...")
                    .frame(maxHeight: .infinity)

            case .loaded(let movies):
                List(movies) { movie in
                    MovieRowView(movie: movie)
                }
                .listStyle(.plain)

            case .empty:
                emptyStateView(message: "No results found")

            case .error(let message):
                emptyStateView(message: message)
            }
        }
        .searchable(text: $viewModel.query, prompt: "Search movies...")
    }

    private func emptyStateView(message: String) -> some View {
        Text(message)
            .foregroundStyle(.secondary)
            .frame(maxHeight: .infinity)
    }
}
