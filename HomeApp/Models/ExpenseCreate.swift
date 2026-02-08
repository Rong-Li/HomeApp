//
//  ExpenseCreate.swift
//  HomeApp
//
//  Family Expense Tracker
//

import Foundation

// MARK: - Currency

enum Currency: String, Codable, CaseIterable {
    case cad = "CAD"
    case rmb = "RMB"
    
    var symbol: String {
        switch self {
        case .cad: return "$"
        case .rmb: return "¥"
        }
    }
    
    var flag: String {
        switch self {
        case .cad: return "🇨🇦"
        case .rmb: return "🇨🇳"
        }
    }
}

// MARK: - ExpenseCreate

struct ExpenseCreate: Encodable {
    let amount: Decimal
    let category: Category
    let transactionType: TransactionType
    let currency: Currency
    let createdAt: Date
    let merchant: String?
    let description: String?
    let recurringPayment: Bool?
    
    enum CodingKeys: String, CodingKey {
        case amount, category, merchant, description, currency
        case transactionType = "transaction_type"
        case createdAt = "created_at"
        case recurringPayment = "recurring_payment"
    }
    
    /// Creates an expense with custom or current timestamp
    init(
        amount: Decimal,
        category: Category,
        transactionType: TransactionType,
        currency: Currency = .cad,
        createdAt: Date = Date(),
        merchant: String? = nil,
        description: String? = nil,
        recurringPayment: Bool? = nil
    ) {
        self.amount = amount
        self.category = category
        self.transactionType = transactionType
        self.currency = currency
        self.createdAt = createdAt
        self.merchant = merchant
        self.description = description
        self.recurringPayment = recurringPayment
    }
}

