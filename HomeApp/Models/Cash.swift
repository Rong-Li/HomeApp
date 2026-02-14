//
//  Cash.swift
//  HomeApp
//
//  Family Expense Tracker
//

import Foundation

// MARK: - Cash Balance

struct CashBalance: Codable {
    let recordType: String
    let balance: Double
    let lastUpdatedDate: String
    
    enum CodingKeys: String, CodingKey {
        case recordType = "record_type"
        case balance
        case lastUpdatedDate = "last_updated_date"
    }
}

// MARK: - Cash Transaction

struct CashTransaction: Identifiable, Codable {
    var id: String { "\(timestamp.timeIntervalSince1970)-\(amount)-\(type.rawValue)" }
    
    let recordType: String
    let amount: Double
    let type: TransactionType
    let timestamp: Date
    
    enum CodingKeys: String, CodingKey {
        case recordType = "record_type"
        case amount, type, timestamp
    }
    
    /// Formatted amount with +/- sign
    var formattedAmount: String {
        let prefix = type == .credit ? "+" : "-"
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "CAD"
        return prefix + (formatter.string(from: NSNumber(value: amount)) ?? "$\(amount)")
    }
    
    /// Timestamp formatted in Toronto timezone
    var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        formatter.timeZone = TimeZone(identifier: "America/Toronto")
        return formatter.string(from: timestamp)
    }
}

// MARK: - Cash Response

struct CashResponse: Codable {
    let balance: CashBalance
    let transactions: [CashTransaction]
}

// MARK: - Cash Transaction Input

struct CashTransactionInput: Encodable {
    let amount: Double
    let type: TransactionType
}
