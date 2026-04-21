//
//  SimpleTokenProvider.swift
//  MovieDataBase
//
//  Created by Vijendran  on 4/20/26.
//

import Foundation

/// Simple implementation of TokenProvider that returns a hardcoded token from Config.
///
/// Used for development and testing. In production, this could be replaced with
/// a more sophisticated implementation that retrieves tokens from Keychain or
/// handles token refresh logic.
final class SimpleTokenProvider: TokenProvider {
    func getToken() async -> String? {
        return Config.authToken
    }
}
