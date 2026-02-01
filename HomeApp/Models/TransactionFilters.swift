//
//  TransactionFilters.swift
//  HomeApp
//
//  Family Expense Tracker
//

import Foundation

struct TransactionFilters: Equatable {
    var selectedCategory: Category?  // Single select
    var transactionType: TransactionType?
    var hasReceipt: Bool?
    var minAmount: Decimal?
    var maxAmount: Decimal?
    
    var isEmpty: Bool {
        selectedCategory == nil && transactionType == nil && hasReceipt == nil && minAmount == nil && maxAmount == nil
    }
    
    var activeCount: Int {
        var count = 0
        if selectedCategory != nil { count += 1 }
        if transactionType != nil { count += 1 }
        if hasReceipt != nil { count += 1 }
        if minAmount != nil || maxAmount != nil { count += 1 }
        return count
    }
    
    mutating func clear() {
        selectedCategory = nil
        transactionType = nil
        hasReceipt = nil
        minAmount = nil
        maxAmount = nil
    }
}
