//
//  APIService.swift
//  HomeApp
//
//  Family Expense Tracker
//

import Foundation

actor APIService {
    private func logRequest(_ method: String, _ urlString: String) {
        #if DEBUG
        print("[API] \(method) \(urlString)")
        #endif
    }
    
    private func logResponse(_ response: URLResponse, data: Data) {
        #if DEBUG
        if let http = response as? HTTPURLResponse {
            print("[API] RESPONSE \(http.statusCode) \(http.url?.absoluteString ?? "")")
            print("[API] HEADERS: \(http.allHeaderFields)")
        }
        if let bodyString = String(data: data, encoding: .utf8) {
            let preview = bodyString.prefix(2_000)
            print("[API] BODY: \(preview)")
        } else {
            print("[API] BODY: <non-UTF8 \(data.count) bytes>")
        }
        #endif
    }
    
    static let shared = APIService()
    
    private let baseURL = "https://tzy15xk1hg.execute-api.ca-central-1.amazonaws.com"
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    // MARK: - Authentication
    
    private var authHeader: [String: String] {
        ["Authorization": "Bearer \(Secrets.apiBearerToken)"]
    }
    
    init() {
        decoder = JSONDecoder()
        
        // Custom date decoder for API format: "2026-01-31T17:21:28.791000"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        
        let dateFormatterNoFraction = DateFormatter()
        dateFormatterNoFraction.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatterNoFraction.timeZone = TimeZone(identifier: "UTC")
        
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            if let date = dateFormatter.date(from: dateString) {
                return date
            } else if let date = dateFormatterNoFraction.date(from: dateString) {
                return date
            } else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date: \(dateString)")
            }
        }
        
        encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        
        // Custom date encoder to match API format: "2026-01-31T17:21:28.791000"
        let dateEncoderFormatter = DateFormatter()
        dateEncoderFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        dateEncoderFormatter.timeZone = TimeZone(identifier: "UTC")
        
        encoder.dateEncodingStrategy = .custom { date, encoder in
            var container = encoder.singleValueContainer()
            let dateString = dateEncoderFormatter.string(from: date)
            try container.encode(dateString)
        }
    }
    
    // MARK: - Fetch Transactions
    
    func fetchTransactions(startDate: Date, endDate: Date) async throws -> [Transaction] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        
        let startDateString = dateFormatter.string(from: startDate)
        let endDateString = dateFormatter.string(from: endDate)
        
        var components = URLComponents(string: "\(baseURL)/expense")
        components?.queryItems = [
            URLQueryItem(name: "start_date", value: startDateString),
            URLQueryItem(name: "end_date", value: endDateString)
        ]
        
        guard let urlString = components?.string, let url = components?.url else {
            throw APIError.invalidURL
        }
        
        logRequest("GET", urlString)
        
        var request = URLRequest(url: url)
        for (key, value) in await authHeader {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        logResponse(response, data: data)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw APIError.serverError(httpResponse.statusCode)
        }
        
        do {
            return try decoder.decode([Transaction].self, from: data)
        } catch {
            #if DEBUG
            print("[API] Decoding error: \(error)")
            #endif
            throw APIError.decodingError
        }
    }
    
    // MARK: - Create Expense
    
    func createExpense(_ expense: ExpenseCreate) async throws -> ExpenseCreateResponse {
        let urlString = "\(baseURL)/expense"
        logRequest("POST", urlString)
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        for (key, value) in await authHeader {
            request.setValue(value, forHTTPHeaderField: key)
        }
        request.httpBody = try encoder.encode(expense)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        logResponse(response, data: data)
        
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
        let urlString = "\(baseURL)/expense/\(transaction.id)"
        logRequest("PUT", urlString)
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        for (key, value) in await authHeader {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        let updateEncoder = JSONEncoder()
        updateEncoder.dateEncodingStrategy = .iso8601
        updateEncoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try updateEncoder.encode(transaction)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        logResponse(response, data: data)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw APIError.serverError(httpResponse.statusCode)
        }
    }
    
    // MARK: - Delete Transaction
    
    func deleteTransaction(id: String) async throws {
        let urlString = "\(baseURL)/expense/\(id)"
        logRequest("DELETE", urlString)
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        for (key, value) in await authHeader {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        logResponse(response, data: data)
        
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
        let urlString = "\(baseURL)/expense/\(transactionId)/receipt/upload-url"
        logRequest("POST", urlString)
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        for (key, value) in await authHeader {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        let body = ["filename": filename, "content_type": contentType]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        logResponse(response, data: data)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.serverError((response as? HTTPURLResponse)?.statusCode ?? 0)
        }
        
        let result = try decoder.decode(UploadUrlResponse.self, from: data)
        return result.uploadUrl
    }
    
    func uploadToS3(url: String, data: Data, contentType: String) async throws {
        logRequest("PUT", url)
        guard let uploadUrl = URL(string: url) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: uploadUrl)
        request.httpMethod = "PUT"
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        
        let (respData, response) = try await URLSession.shared.data(for: request)
        logResponse(response, data: respData)
        
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
        let urlString = "\(baseURL)/expense/\(transactionId)/receipt/confirm"
        logRequest("POST", urlString)
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        for (key, value) in await authHeader {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        let body = ["filename": filename]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        logResponse(response, data: data)
        
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
        let urlString = "\(baseURL)/expense/\(transactionId)/receipt/view-url"
        logRequest("GET", urlString)
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        for (key, value) in await authHeader {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        logResponse(response, data: data)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.serverError((response as? HTTPURLResponse)?.statusCode ?? 0)
        }
        
        return try decoder.decode(ViewUrlResponse.self, from: data)
    }
}

