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
        Group {
            switch viewModel.state {
            case .idle:
                Color.clear
                    .onAppear {
                        Task { await viewModel.fetchMovies() }
                    }

            case .loading:
                ProgressView("Loading movies...")

            case .loaded(let movies):
                List(movies) { movie in
                    MovieRowView(movie: movie)
                }
                .listStyle(.plain)
                .refreshable {
                    await viewModel.fetchMovies()
                }

            case .error(let message):
                VStack(spacing: 16) {
                    Text(message)
                        .foregroundStyle(.secondary)
                    Button("Retry") {
                        Task { await viewModel.fetchMovies() }
                    }
                }
            }
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
