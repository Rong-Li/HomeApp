//
//  ExpenseCreate.swift
//  HomeApp
//
//  Family Expense Tracker
//

import Foundation

struct ExpenseCreate: Encodable {
    let amount: Decimal
    let category: Category
    let transactionType: TransactionType
    let createdAt: Date
    let merchant: String?
    let description: String?
    let recurringPayment: Bool?
    
    enum CodingKeys: String, CodingKey {
        case amount, category, merchant, description
        case transactionType = "transaction_type"
        case createdAt = "created_at"
        case recurringPayment = "recurring_payment"
    }
    
    /// Creates an expense with custom or current timestamp
    init(
        amount: Decimal,
        category: Category,
        transactionType: TransactionType,
        createdAt: Date = Date(),
        merchant: String? = nil,
        description: String? = nil,
        recurringPayment: Bool? = nil
    ) {
        self.amount = amount
        self.category = category
        self.transactionType = transactionType
        self.createdAt = createdAt
        self.merchant = merchant
        self.description = description
        self.recurringPayment = recurringPayment
    }
}
