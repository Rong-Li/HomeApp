//
//  TransactionsViewModel.swift
//  HomeApp
//
//  Family Expense Tracker
//

import SwiftUI
import Observation

@Observable
class TransactionsViewModel {
    // Data
    private var allTransactions: [Transaction] = []
    var displayedCount: Int = 30
    
    // Filters
    var searchText: String = ""
    var selectedTimeRange: TimeRange = .oneMonth
    var filters: TransactionFilters = TransactionFilters()
    
    // UI State
    var isLoading: Bool = false
    var error: APIError?
    
    // Dependencies
    private let apiService = APIService.shared
    
    // Computed - filtered transactions
    var filteredTransactions: [Transaction] {
        var result = allTransactions
        
        // Category filter (single select)
        if let category = filters.selectedCategory {
            result = result.filter { $0.category == category }
        }
        
        // Transaction type filter
        if let type = filters.transactionType {
            result = result.filter { $0.transactionType == type }
        }
        
        // Has receipt filter
        if let hasReceipt = filters.hasReceipt {
            result = result.filter { $0.hasReceipt == hasReceipt }
        }
        
        // Recurring payment filter
        if let recurring = filters.recurringPayment {
            result = result.filter { $0.recurringPayment == recurring }
        }
        
        // Amount range filter
        if let min = filters.minAmount {
            result = result.filter { $0.amount >= min }
        }
        if let max = filters.maxAmount {
            result = result.filter { $0.amount <= max }
        }
        
        // Search filter
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            result = result.filter { transaction in
                transaction.category.displayName.lowercased().contains(query) ||
                transaction.merchant?.lowercased().contains(query) == true ||
                transaction.description?.lowercased().contains(query) == true ||
                String(describing: transaction.amount).contains(query)
            }
        }
        
        // Sort by date descending
        result.sort { $0.createdAt > $1.createdAt }
        
        return result
    }
    
    // Transactions to display (client-side pagination)
    var displayedTransactions: [Transaction] {
        Array(filteredTransactions.prefix(displayedCount))
    }
    
    var canLoadMore: Bool {
        displayedCount < filteredTransactions.count
    }
    
    // MARK: - Actions
    
    func loadTransactions() async {
        guard !isLoading else { return }
        
        isLoading = true
        error = nil
        displayedCount = 30
        
        do {
            let startDate = selectedTimeRange.startDate
            let endDate = Date()
            allTransactions = try await apiService.fetchTransactions(startDate: startDate, endDate: endDate)
        } catch {
            self.error = error as? APIError ?? .unknown
        }
        
        isLoading = false
    }
    
    func loadMore() {
        displayedCount += 30
    }
    
    func refresh() async {
        await loadTransactions()
    }
}
