//
//  MovieListView.swift
//  MovieDataBase
//
//  Created by Vijendran  on 4/15/26.
//

import SwiftUI
import Kingfisher

/// Main view displaying the list of popular movies.
struct MovieListView: View {
    @ObservedObject var viewModel: MovieListViewModel

    
    var body: some View {
        VStack {
            List {
                ForEach(viewModel.movies) { movie in
                    MovieRowView(movie: movie)
                }
                if viewModel.showLoadMore {
                    Text("Loading...")
                        .font(.callout)
                        .frame(maxWidth:.infinity, alignment: .center)
                        .listRowSeparator(.hidden)
                }
            }
            .listStyle(.plain)
            .refreshable {
                await viewModel.fetchMovies()
            }
            .onScrollGeometryChange(for: Bool.self) { geometry in
                let maxOffset = geometry.contentSize.height - geometry.containerSize.height
                return geometry.contentOffset.y >= maxOffset - 400
            } action: { wasNearBottom, isNearBottom in
                if isNearBottom == true && wasNearBottom != isNearBottom {
                    Task {
                        await viewModel.fetchMoreMovies()
                    }
                }
            }
        }
        .overlay(alignment: .center, content: {
            switch viewModel.state {
                case .idle:
                    EmptyView()

                case .loading:
                    ProgressView("Loading movies...")

                case .loaded:
                    EmptyView()
                   
                case .error(let message):
                    VStack(spacing: 16) {
                        Text(message)
                            .foregroundStyle(.secondary)
                        Button("Retry") {
                            Task { await viewModel.fetchMovies() }
                        }
                    }
            }
        })
        .navigationTitle("Movies")
        .onAppear {
            Task { await viewModel.fetchMovies() }
        }
    }
}

/// Row view displaying a single movie's information.
struct MovieRowView: View {
    let movie: Movie

    private var posterURL: URL? {
        guard let path = movie.posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w185\(path)")
    }

    private var releaseYear: String {
        String(movie.releaseDate.prefix(4))
    }

    var body: some View {
        HStack(spacing: 12) {
            KFImage(posterURL)
                .placeholder {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                }
                .resizable()
                .aspectRatio(2/3, contentMode: .fit)
                .frame(width: 60)
                .cornerRadius(4)

            VStack(alignment: .leading, spacing: 4) {
                Text(movie.title)
                    .font(.headline)
                    .lineLimit(2)

                Text(releaseYear)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                        .font(.caption)
                    Text(String(format: "%.1f", movie.voteAverage))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        MovieListView(viewModel: MovieListViewModel(repository: MockMovieRepository()))
    }
}
