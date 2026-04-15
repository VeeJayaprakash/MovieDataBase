//
//  UserRepositoryProtocol.swift
//  MovieDataBase
//
//  Created by Vijendran  on 4/15/26.
//

import Foundation

/// Protocol defining user data access operations.
protocol UserRepositoryProtocol {
    /// Fetches the current user's account details.
    /// - Returns: User detail information.
    func fetchUserDetail() async throws -> UserDetail
}
