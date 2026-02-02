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
    var merchant: String = ""
    var note: String = ""
    
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
            return "$0.00"
        }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "CAD"
        return formatter.string(from: amount as NSDecimalNumber) ?? "$0.00"
    }
    
    var submitButtonTitle: String {
        transactionType == .debit ? "Log Expense" : "Log Income"
    }
    
    var successMessage: String {
        let prefix = transactionType == .debit ? "-" : "+"
        return "\(selectedCategory.displayName) \(prefix)\(formattedAmount)"
    }
    
    // MARK: - Actions
    
    func appendDigit(_ digit: String) {
        // Handle decimal places (max 2)
        if digit == "." && amountString.contains(".") { return }
        if let dotIndex = amountString.firstIndex(of: ".") {
            let decimals = amountString.distance(from: dotIndex, to: amountString.endIndex) - 1
            if decimals >= 2 && digit != "." { return }
        }
        // Prevent leading zeros (except for "0.")
        if amountString == "0" && digit != "." {
            amountString = digit
            return
        }
        amountString += digit
    }
    
    func deleteLastDigit() {
        if !amountString.isEmpty {
            amountString.removeLast()
        }
    }
    
    func submit() async {
        guard isAmountValid, let amount = amount else { return }
        
        isSubmitting = true
        error = nil
        
        do {
            let expense = ExpenseCreate(
                amount: amount,
                category: selectedCategory,
                transactionType: transactionType,
                merchant: merchant.isEmpty ? nil : merchant,
                description: note.isEmpty ? nil : note,
                recurringPayment: nil
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
        merchant = ""
        note = ""
        isSubmitting = false
        showSuccess = false
        error = nil
    }
}
