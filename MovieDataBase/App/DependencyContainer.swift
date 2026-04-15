//
//  DependencyContainer.swift
//  MovieDataBase
//
//  Created by Vijendran  on 4/15/26.
//

import Foundation

/// Simple dependency container for providing repositories and services.
///
/// Created at app startup and passed to coordinators.
final class DependencyContainer {
    private let networkClient: NetworkClient

    init() {
        networkClient = NetworkClient(baseURL: "https://api.themoviedb.org")
    }

    // MARK: - Repositories

    func makeMovieRepository() -> MovieRepositoryProtocol {
        MovieRepository(client: networkClient)
    }

    func makeMockMovieRepository() -> MovieRepositoryProtocol {
        MockMovieRepository()
    }

    func makeUserRepository() -> UserRepositoryProtocol {
        UserRepository(client: networkClient)
    }

    func makeMockUserRepository() -> UserRepositoryProtocol {
        MockUserRepository()
    }
}
