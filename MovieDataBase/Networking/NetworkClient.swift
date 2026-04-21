//
//  NetworkClient.swift
//  MovieDataBase
//
//  Created by Vijendran  on 4/15/26.
//

import Foundation

/// A generic network client using async/await for API requests.
///
/// Handles URL construction, request execution, and response decoding.
/// Maps HTTP errors and URLSession errors to typed NetworkError cases.
class NetworkClient {
    /// Base URL for all API requests.
    private let baseURL: String

    /// URL session for network requests.
    private let session: URLSession

    /// Token provider for authentication.
    private let tokenProvider: TokenProvider?

    /// JSON decoder configured for TMDB API responses.
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    init(baseURL: String, session: URLSession = .shared, tokenProvider: TokenProvider? = nil) {
        self.baseURL = baseURL
        self.session = session
        self.tokenProvider = tokenProvider
    }

    /// Executes a network request and decodes the response.
    ///
    /// - Parameter endpoint: The endpoint configuration for the request.
    /// - Returns: Decoded response of type T.
    /// - Throws: NetworkError if the request fails.
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        guard var urlComponents = URLComponents(string: baseURL + endpoint.path) else {
            throw NetworkError.badURL
        }

        urlComponents.queryItems = endpoint.queryItems

        guard let url = urlComponents.url else {
            throw NetworkError.badURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = endpoint.method.rawValue
        urlRequest.httpBody = endpoint.body

        // Add Authorization header if token is available
        if let token = await tokenProvider?.getToken() {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        endpoint.headers?.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: urlRequest)
        } catch {
            throw NetworkError.urlError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.urlError(URLError(.badServerResponse))
        }

        switch httpResponse.statusCode {
        case 200...299:
            break
        case 401:
            throw NetworkError.unauthorized
        default:
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed(error)
        }
    }
}
