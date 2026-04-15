//
//  Endpoint.swift
//  MovieDataBase
//
//  Created by Vijendran  on 4/15/26.
//

import Foundation

/// HTTP methods supported by the network client.
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

/// Defines an API endpoint configuration.
///
/// Bundles path, HTTP method, query parameters, headers, and body
/// needed by NetworkClient to construct a URLRequest.
struct Endpoint {
    /// The path component of the URL (e.g., "/3/discover/movie").
    let path: String

    /// The HTTP method for this endpoint.
    let method: HTTPMethod

    /// Optional query parameters to append to the URL.
    let queryItems: [URLQueryItem]?

    /// Optional HTTP headers to include in the request.
    let headers: [String: String]?

    /// Optional request body for POST requests.
    let body: Data?

    init(
        path: String,
        method: HTTPMethod = .get,
        queryItems: [URLQueryItem]? = nil,
        headers: [String: String]? = nil,
        body: Data? = nil
    ) {
        self.path = path
        self.method = method
        self.queryItems = queryItems
        self.headers = headers
        self.body = body
    }
}
