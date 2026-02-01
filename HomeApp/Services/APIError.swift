//
//  APIError.swift
//  HomeApp
//
//  Family Expense Tracker
//

import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(Int)
    case decodingError
    case networkUnavailable
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .invalidResponse: return "Invalid response from server"
        case .serverError(let code): return "Server error: \(code)"
        case .decodingError: return "Failed to process data"
        case .networkUnavailable: return "No internet connection"
        case .unknown: return "An unknown error occurred"
        }
    }
}
