//
//  APIService.swift
//  HomeApp
//
//  Family Expense Tracker
//

import Foundation

actor APIService {
    static let shared = APIService()
    
    private let baseURL = "https://tzy15xk1hg.execute-api.ca-central-1.amazonaws.com"
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    init() {
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
    }
    
    // MARK: - Fetch Transactions
    
    func fetchTransactions() async throws -> [Transaction] {
        guard let url = URL(string: "\(baseURL)/expenses") else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw APIError.serverError(httpResponse.statusCode)
        }
        
        do {
            let result = try decoder.decode(TransactionsResponse.self, from: data)
            return result.expenses
        } catch {
            print("Decoding error: \(error)")
            throw APIError.decodingError
        }
    }
    
    // MARK: - Create Expense
    
    func createExpense(_ expense: ExpenseCreate) async throws -> ExpenseCreateResponse {
        guard let url = URL(string: "\(baseURL)/expense") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(expense)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 || httpResponse.statusCode == 201 else {
            throw APIError.serverError(httpResponse.statusCode)
        }
        
        return try decoder.decode(ExpenseCreateResponse.self, from: data)
    }
    
    // MARK: - Update Transaction
    
    func updateTransaction(_ transaction: Transaction) async throws {
        guard let url = URL(string: "\(baseURL)/expense/\(transaction.id)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let updateEncoder = JSONEncoder()
        updateEncoder.dateEncodingStrategy = .iso8601
        updateEncoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try updateEncoder.encode(transaction)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw APIError.serverError(httpResponse.statusCode)
        }
    }
    
    // MARK: - Delete Transaction
    
    func deleteTransaction(id: String) async throws {
        guard let url = URL(string: "\(baseURL)/expense/\(id)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw APIError.serverError(httpResponse.statusCode)
        }
    }
    
    // MARK: - Receipt Upload (S3 Pre-signed URL)
    
    struct UploadUrlResponse: Decodable {
        let uploadUrl: String
        let expiresIn: Int
        
        enum CodingKeys: String, CodingKey {
            case uploadUrl = "upload_url"
            case expiresIn = "expires_in"
        }
    }
    
    func getReceiptUploadUrl(transactionId: String, filename: String, contentType: String) async throws -> String {
        guard let url = URL(string: "\(baseURL)/expense/\(transactionId)/receipt/upload-url") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["filename": filename, "content_type": contentType]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.serverError((response as? HTTPURLResponse)?.statusCode ?? 0)
        }
        
        let result = try decoder.decode(UploadUrlResponse.self, from: data)
        return result.uploadUrl
    }
    
    func uploadToS3(url: String, data: Data, contentType: String) async throws {
        guard let uploadUrl = URL(string: url) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: uploadUrl)
        request.httpMethod = "PUT"
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.serverError((response as? HTTPURLResponse)?.statusCode ?? 0)
        }
    }
    
    struct ConfirmUploadResponse: Decodable {
        let message: String
        let receiptId: String
        
        enum CodingKeys: String, CodingKey {
            case message
            case receiptId = "receipt_id"
        }
    }
    
    func confirmReceiptUpload(transactionId: String, filename: String) async throws -> String {
        guard let url = URL(string: "\(baseURL)/expense/\(transactionId)/receipt/confirm") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["filename": filename]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.serverError((response as? HTTPURLResponse)?.statusCode ?? 0)
        }
        
        let result = try decoder.decode(ConfirmUploadResponse.self, from: data)
        return result.receiptId
    }
    
    // MARK: - Receipt Download (S3 Pre-signed URL)
    
    struct ViewUrlResponse: Decodable {
        let viewUrl: String
        let expiresIn: Int
        let contentType: String
        
        enum CodingKeys: String, CodingKey {
            case viewUrl = "view_url"
            case expiresIn = "expires_in"
            case contentType = "content_type"
        }
    }
    
    func getReceiptViewUrl(transactionId: String) async throws -> ViewUrlResponse {
        guard let url = URL(string: "\(baseURL)/expense/\(transactionId)/receipt/view-url") else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.serverError((response as? HTTPURLResponse)?.statusCode ?? 0)
        }
        
        return try decoder.decode(ViewUrlResponse.self, from: data)
    }
}
