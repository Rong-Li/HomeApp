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
    let merchant: String?
    let description: String?
    
    enum CodingKeys: String, CodingKey {
        case amount, category, merchant, description
        case transactionType = "transaction_type"
    }
}
