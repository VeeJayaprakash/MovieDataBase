//
//  UserRepository.swift
//  MovieDataBase
//
//  Created by Vijendran  on 4/15/26.
//

import Foundation

/// Concrete implementation of UserRepositoryProtocol using NetworkClient.
final class UserRepository: UserRepositoryProtocol {
    private let client: NetworkClient

    init(client: NetworkClient) {
        self.client = client
    }

    func fetchUserDetail() async throws -> UserDetail {
        let endpoint = Endpoint(path: "/3/account")
        return try await client.request(endpoint)
    }
}

/// Mock implementation of UserRepositoryProtocol for previews and testing.
final class MockUserRepository: UserRepositoryProtocol {
    func fetchUserDetail() async throws -> UserDetail {
        try loadJSON(filename: "MockAccountDetail")
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
