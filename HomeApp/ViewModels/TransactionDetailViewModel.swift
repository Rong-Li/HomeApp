//
//  TransactionDetailViewModel.swift
//  HomeApp
//
//  Family Expense Tracker
//

import SwiftUI
import Observation

@Observable
class TransactionDetailViewModel {
    var transaction: Transaction
    var isLoading = false
    var isSaving = false
    var isDeleting = false
    var error: String?
    
    private let apiService = APIService.shared
    
    init(transaction: Transaction) {
        self.transaction = transaction
    }
    
    var formattedFullDateTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: transaction.createdAt)
    }
    
    // MARK: - Actions
    
    func saveTransaction(_ updated: Transaction) async throws {
        isSaving = true
        error = nil
        defer { isSaving = false }
        
        try await apiService.updateTransaction(updated)
        transaction = updated
    }
    
    func deleteTransaction() async throws {
        isDeleting = true
        error = nil
        defer { isDeleting = false }
        
        try await apiService.deleteTransaction(id: transaction.id)
    }
}
