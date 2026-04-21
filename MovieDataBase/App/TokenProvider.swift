//
//  TokenProvider.swift
//  MovieDataBase
//
//  Created by Vijendran  on 4/20/26.
//

import Foundation

/// Protocol for providing authentication tokens to the network layer.
///
/// Implementations can provide tokens from various sources:
/// - Hardcoded configuration (development)
/// - Keychain storage (production)
/// - Token refresh services (future enhancement)
protocol TokenProvider {
    /// Retrieves the current authentication token.
    ///
    /// - Returns: Bearer token string, or nil if no token is available.
    func getToken() async -> String?
}
