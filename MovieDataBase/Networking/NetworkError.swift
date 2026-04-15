//
//  NetworkError.swift
//  MovieDataBase
//
//  Created by Vijendran  on 4/15/26.
//

import Foundation

/// Errors that can occur during network operations.
enum NetworkError: Error {
    case badURL
    case unauthorized
    case serverError(statusCode: Int)
    case decodingFailed(Error)
    case urlError(Error)
}
