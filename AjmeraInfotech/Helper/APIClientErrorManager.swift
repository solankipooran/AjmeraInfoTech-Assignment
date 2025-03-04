//
//  APIClientErrorManager.swift
//  AjmeraInfotech
//
//  Created by Pooran Kumar on 03/03/25.
//

import Foundation

enum APIClientError: Error, LocalizedError {
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from the server."
        case .httpError(let statusCode):
            return "\(message(statusCode))"
        case .decodingError(let error):
            return "Decoding Error: \(error.localizedDescription)"
        case .unknown(let error):
            return "Unknown Error: \(error.localizedDescription)"
        }
    }
    
    private func message(_ statusCode: Int) -> String {
        switch statusCode {
        case 400:
            return "Bad request"
        case 401:
            return "Unauthorized"
        case 404:
            return "This email is not registered,Please signUp"
        case 408:
            return "Request timed out, Try again"
        case 409:
            return "You are already register with this email"
        default:
            return "Something is wrong"
        }
    }
}
