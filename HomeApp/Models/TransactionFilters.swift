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
    var selectedCurrency: Currency?
    var recurringPayment: Bool?
    var minAmount: Decimal?
    var maxAmount: Decimal?
    
    var isEmpty: Bool {
        selectedCategory == nil && transactionType == nil && selectedCurrency == nil && recurringPayment == nil && minAmount == nil && maxAmount == nil
    }
    
    var activeCount: Int {
        var count = 0
        if selectedCategory != nil { count += 1 }
        if transactionType != nil { count += 1 }
        if selectedCurrency != nil { count += 1 }
        if recurringPayment != nil { count += 1 }
        if minAmount != nil || maxAmount != nil { count += 1 }
        return count
    }
    
    mutating func clear() {
        selectedCategory = nil
        transactionType = nil
        selectedCurrency = nil
        recurringPayment = nil
        minAmount = nil
        maxAmount = nil
    }
}
