//
//  UserDetail.swift
//  MovieDataBase
//
//  Created by Vijendran  on 4/15/26.
//

import Foundation

/// Represents user account details from the TMDB API.
struct UserDetail: Codable, Identifiable {
    let id: Int
    let name: String
    let includeAdult: Bool
    let username: String
    let avatar: Avatar
}

/// Container for user avatar information.
struct Avatar: Codable {
    let gravatar: Gravatar
    let tmdb: TMDBAvatar
}

/// Gravatar avatar information.
struct Gravatar: Codable {
    let hash: String
}

/// TMDB avatar information.
struct TMDBAvatar: Codable {
    let avatarPath: String?
}
