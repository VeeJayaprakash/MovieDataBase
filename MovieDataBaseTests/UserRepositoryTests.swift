//
//  UserRepositoryTests.swift
//  MovieDataBaseTests
//
//  Created by Vijendran  on 4/15/26.
//

import XCTest
@testable import MovieDataBase

final class UserRepositoryTests: XCTestCase {

    var sut: UserRepository!
    var mockClient: MockNetworkClient!

    override func setUp() {
        super.setUp()
        mockClient = MockNetworkClient()
        sut = UserRepository(client: mockClient)
    }

    override func tearDown() {
        sut = nil
        mockClient = nil
        super.tearDown()
    }

    // MARK: - Fetch User Detail

    func test_fetchUserDetail_createsCorrectEndpoint() async throws {
        // Given
        let expectedUser = UserDetail(
            id: 1,
            name: "Test User",
            includeAdult: false,
            username: "testuser",
            avatar: Avatar(
                gravatar: Gravatar(hash: "abc123"),
                tmdb: TMDBAvatar(avatarPath: nil)
            )
        )
        mockClient.result = .success(expectedUser)

        // When
        _ = try await sut.fetchUserDetail()

        // Then
        XCTAssertEqual(mockClient.capturedEndpoint?.path, "/3/account")
        XCTAssertEqual(mockClient.capturedEndpoint?.method, .get)
    }

    func test_fetchUserDetail_returnsUserDetail() async throws {
        // Given
        let expectedUser = UserDetail(
            id: 123,
            name: "John Doe",
            includeAdult: false,
            username: "johndoe",
            avatar: Avatar(
                gravatar: Gravatar(hash: "hash123"),
                tmdb: TMDBAvatar(avatarPath: "/path/to/avatar.jpg")
            )
        )
        mockClient.result = .success(expectedUser)

        // When
        let user = try await sut.fetchUserDetail()

        // Then
        XCTAssertEqual(user.id, 123)
        XCTAssertEqual(user.name, "John Doe")
        XCTAssertEqual(user.username, "johndoe")
        XCTAssertEqual(user.includeAdult, false)
        XCTAssertEqual(user.avatar.gravatar.hash, "hash123")
        XCTAssertEqual(user.avatar.tmdb.avatarPath, "/path/to/avatar.jpg")
    }

    func test_fetchUserDetail_throwsError() async {
        // Given
        mockClient.result = .failure(NetworkError.serverError(statusCode: 500))

        // When/Then
        do {
            _ = try await sut.fetchUserDetail()
            XCTFail("Expected error")
        } catch {
            XCTAssertTrue(error is NetworkError)
        }
    }
}
