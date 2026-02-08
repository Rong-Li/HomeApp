//
//  ExpenseLoggerViewModel.swift
//  HomeApp
//
//  Family Expense Tracker
//

import SwiftUI
import Observation

@Observable
class ExpenseLoggerViewModel {
    // Input state
    var amountString: String = ""
    var transactionType: TransactionType = .debit
    var selectedCategory: Category = .groceries
    var selectedCurrency: Currency = .cad
    var merchant: String = ""
    var note: String = ""
    var selectedDate: Date = Date()
    
    // UI state
    var isSubmitting: Bool = false
    var showSuccess: Bool = false
    var error: String?
    
    // Computed
    var amount: Decimal? {
        Decimal(string: amountString)
    }
    
    var isAmountValid: Bool {
        guard let amount = amount else { return false }
        return amount > 0
    }
    
    var formattedAmount: String {
        guard let amount = amount else {
            return "\(selectedCurrency.symbol)0.00"
        }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = selectedCurrency.rawValue
        return formatter.string(from: amount as NSDecimalNumber) ?? "\(selectedCurrency.symbol)0.00"
    }
    
    var successMessage: String {
        let prefix = transactionType == .debit ? "-" : "+"
        return "\(selectedCategory.displayName) \(prefix)\(formattedAmount)"
    }
    
    // MARK: - Actions
    
    func requestLocationPermission() {
        LocationService.shared.requestPermission()
    }
    
    func submit() async {
        guard isAmountValid, let amount = amount else { return }
        
        isSubmitting = true
        error = nil
        
        do {
            // Fetch postal code (non-blocking, nil if unavailable)
            let postalCode = await LocationService.shared.fetchPostalCode()
            
            let expense = ExpenseCreate(
                amount: amount,
                category: selectedCategory,
                transactionType: transactionType,
                currency: selectedCurrency,
                createdAt: selectedDate,
                merchant: merchant.isEmpty ? nil : merchant,
                description: note.isEmpty ? nil : note,
                recurringPayment: nil,
                postalCode: postalCode
            )
            
            _ = try await APIService.shared.createExpense(expense)
            
            await MainActor.run {
                showSuccess = true
            }
            
        } catch {
            await MainActor.run {
                self.error = "Failed to save. Try again."
                isSubmitting = false
            }
        }
    }
    
    func reset() {
        amountString = ""
        transactionType = .debit
        selectedCategory = .groceries
        selectedCurrency = .cad
        merchant = ""
        note = ""
        selectedDate = Date()
        isSubmitting = false
        showSuccess = false
        error = nil
    }
}
