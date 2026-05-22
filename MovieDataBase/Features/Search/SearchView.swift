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
                emptyStateView(message: "Start by typing movie name")

            case .loading:
                ProgressView("Searching...")
                    .frame(maxHeight: .infinity)

            case .loaded:
                List {
                    ForEach(viewModel.movies) { movie in
                        MovieRowView(movie: movie)
                    }
                    if viewModel.showLoadMore {
                        Text("Loading...")
                            .font(.callout)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
                .onScrollGeometryChange(for: Bool.self) { geometry in
                    let maxOffset = geometry.contentSize.height - geometry.containerSize.height
                    return geometry.contentOffset.y >= maxOffset - 400
                } action: { wasNearBottom, isNearBottom in
                    if isNearBottom == true && wasNearBottom != isNearBottom {
                        Task {
                            await viewModel.fetchMoreResults()
                        }
                    }
                }

            case .empty:
                emptyStateView(message: "No results found")

            case .error(let message):
                emptyStateView(message: message)
            }
        }
        .searchable(text: $viewModel.query, placement:.navigationBarDrawer, prompt: "Search movies...")
        .navigationTitle("Search Movies")

    }

    private func emptyStateView(message: String) -> some View {
        Text(message)
            .foregroundStyle(.secondary)
            .frame(maxHeight: .infinity)
    }
}

#Preview {
    NavigationStack {
        SearchView(viewModel: SearchViewModel(repository: MockMovieRepository()))
    }
}
