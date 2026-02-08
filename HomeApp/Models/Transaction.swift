//
//  Transaction.swift
//  HomeApp
//
//  Family Expense Tracker
//

import Foundation

struct Transaction: Identifiable, Codable, Equatable, Hashable {
    let id: String
    var amount: Decimal
    var category: Category
    var transactionType: TransactionType
    var currency: Currency
    var createdAt: Date
    var merchant: String?
    var description: String?
    var receiptId: String?
    var recurringPayment: Bool?
    
    var isCredit: Bool {
        transactionType == .credit
    }
    
    var hasReceipt: Bool {
        receiptId != nil
    }
    
    var displaySubtitle: String? {
        merchant ?? description
    }
    
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency.rawValue
        let prefix = isCredit ? "+" : "-"
        return prefix + (formatter.string(from: amount as NSDecimalNumber) ?? "\(currency.symbol)0.00")
    }
    
    var formattedDateTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, h:mm a"
        return formatter.string(from: createdAt)
    }
    
    var formattedFullDateTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: createdAt)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, amount, category, merchant, description, currency
        case transactionType = "transaction_type"
        case createdAt = "created_at"
        case receiptId = "receipt_id"
        case recurringPayment = "recurring_payment"
    }
}

// MARK: - API Response Models

struct TransactionsResponse: Decodable {
    let expenses: [Transaction]
}

struct ExpenseCreateResponse: Decodable {
    let message: String
    let expenseId: String
    
    enum CodingKeys: String, CodingKey {
        case message
        case expenseId = "expense_id"
    }
}

struct MessageResponse: Decodable {
    let message: String
}
