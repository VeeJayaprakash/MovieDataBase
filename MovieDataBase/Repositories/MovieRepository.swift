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
}
