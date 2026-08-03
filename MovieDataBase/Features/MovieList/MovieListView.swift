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
    @Namespace var movieItemNamespace
    
    var gridItemArray:[GridItem] {
        return [GridItem(.adaptive(minimum: 150, maximum: 180))]
    }
    
    @State var selectedMovie:Movie? = nil
    
    var body: some View {
        ZStack {
                ScrollView {
                    LazyVGrid(columns: gridItemArray) {
                        ForEach(viewModel.movies) { movie in
                            MovieGridItem(movie: movie)
                                .onTapGesture {
                                    viewModel.selected(movie: movie)
                                }
                        }
                        if viewModel.showLoadMore {
                            Text("Loading...")
                                .font(.callout)
                                .frame(maxWidth:.infinity, alignment: .center)
                                .listRowSeparator(.hidden)
                        }
                    }
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
                .navigationTitle("Popular Movies")
                .onAppear {
                    Task {
                        if viewModel.movies.isEmpty {
                            await viewModel.fetchMovies()
                        }
                    }
                }
        }
    }
}

/// Row view displaying a single movie's information.
  

#Preview {
    NavigationStack {
        MovieListView(viewModel: MovieListViewModel(repository: MockMovieRepository(), onMovieSelected:nil))
    }
}
