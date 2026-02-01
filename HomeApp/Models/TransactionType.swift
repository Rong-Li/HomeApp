//
//  TransactionType.swift
//  HomeApp
//
//  Family Expense Tracker
//

import Foundation

enum TransactionType: String, Codable {
    case credit = "Credit"
    case debit = "Debit"
    
    var displayName: String {
        rawValue
    }
}
