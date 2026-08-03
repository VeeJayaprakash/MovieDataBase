//
//  MovieRepository.swift
//  MovieDataBase
//
//  Created by Vijendran  on 4/15/26.
//

import Foundation

/// Concrete implementation of MovieRepositoryProtocol using NetworkClient.
final class MovieRepository: MovieRepositoryProtocol {
    private let client: NetworkClient

    init(client: NetworkClient) {
        self.client = client
    }

    func fetchPopularMovies(page: Int) async throws -> MovieListResponse {
        let endpoint = Endpoint(
            path: "/3/discover/movie",
            queryItems: [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "sort_by", value: "popularity.desc")
            ]
        )
        return try await client.request(endpoint)
    }

    func searchMovies(query: String, page: Int) async throws -> MovieListResponse {
        let endpoint = Endpoint(
            path: "/3/search/movie",
            queryItems: [
                URLQueryItem(name: "query", value: query),
                URLQueryItem(name: "page", value: "\(page)")
            ]
        )
        return try await client.request(endpoint)
    }
}

/// Mock implementation of MovieRepositoryProtocol for previews and testing.
final class MockMovieRepository: MovieRepositoryProtocol {
    func fetchPopularMovies(page: Int) async throws -> MovieListResponse {
        try loadJSON(filename: "MockDiscoverMovies")
    }

    func searchMovies(query: String, page: Int) async throws -> MovieListResponse {
        try loadJSON(filename: "MockSearchMovies")
    }

    private func loadJSON<T: Decodable>(filename: String) throws -> T {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            throw NetworkError.badURL
        }
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(T.self, from: data)
    }
    
    func mockMovie() -> Movie {
        Movie(id: 640146,
              adult: false, backdropPath: "/8YFL5QQVPy3AgrEQxNYVSgiPEbe.jpg", genreIds: [28,12,878], originalLanguage: "en", originalTitle: "Ant-Man and the Wasp: Quantumania", overview: "Super-Hero partners Scott Lang and Hope van Dyne, along with with Hope's parents Janet van Dyne and Hank Pym, and Scott's daughter Cassie Lang, find themselves exploring the Quantum Realm, interacting with strange new creatures and embarking on an adventure that will push them beyond the limits of what they thought possible.", popularity:  9272.643, posterPath: "/ngl2FKBlU4fhbdsrtdom9LVLBXw.jpg", releaseDate: "2023-02-15", title: "Ant-Man and the Wasp: Quantumania", video: false, voteAverage: 6.5, voteCount: 1856)
    }
}
