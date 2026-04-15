//
//  MovieRepositoryProtocol.swift
//  MovieDataBase
//
//  Created by Vijendran  on 4/15/26.
//

import Foundation

/// Protocol defining movie data access operations.
protocol MovieRepositoryProtocol {
    /// Fetches popular/discover movies.
    /// - Parameter page: Page number for pagination.
    /// - Returns: Paginated movie list response.
    func fetchPopularMovies(page: Int) async throws -> MovieListResponse

    /// Searches movies by query string.
    /// - Parameters:
    ///   - query: Search term.
    ///   - page: Page number for pagination.
    /// - Returns: Paginated movie list response.
    func searchMovies(query: String, page: Int) async throws -> MovieListResponse
}
