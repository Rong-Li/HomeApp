//
//  CashViewModel.swift
//  HomeApp
//
//  Family Expense Tracker
//

import SwiftUI
import Observation

@Observable
class CashViewModel {
    // Data
    var cashResponse: CashResponse?
    
    // UI State
    var isLoading: Bool = false
    var isSaving: Bool = false
    var error: APIError?
    
    // Input
    var amountText: String = ""
    var selectedType: TransactionType = .debit
    
    // Dependencies
    private let apiService = APIService.shared
    
    var balance: Double {
        cashResponse?.balance.balance ?? 0
    }
    
    var transactions: [CashTransaction] {
        cashResponse?.transactions ?? []
    }
    
    var formattedBalance: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "CAD"
        return formatter.string(from: NSNumber(value: balance)) ?? "$0.00"
    }
    
    // MARK: - Actions
    
    func loadStatus() async {
        guard !isLoading else { return }
        
        isLoading = true
        error = nil
        
        do {
            cashResponse = try await apiService.fetchCashStatus()
        } catch {
            self.error = error as? APIError ?? .unknown
        }
        
        isLoading = false
    }
    
    func addTransaction() async -> Bool {
        guard let amount = Double(amountText), amount > 0 else { return false }
        
        isSaving = true
        defer { isSaving = false }
        
        let input = CashTransactionInput(amount: amount, type: selectedType)
        
        do {
            try await apiService.addCashTransaction(input)
            amountText = ""
            await loadStatus()
            return true
        } catch {
            self.error = error as? APIError ?? .unknown
            return false
        }
    }
    
    func resetData() async -> Bool {
        isSaving = true
        defer { isSaving = false }
        
        do {
            try await apiService.resetCashData()
            cashResponse = nil
            await loadStatus()
            return true
        } catch {
            self.error = error as? APIError ?? .unknown
            return false
        }
    }
}
