//
//  BalanceViewModel.swift
//  HomeApp
//
//  Family Expense Tracker
//

import SwiftUI
import Observation

@Observable
class BalanceViewModel {
    var balances: [Balance] = []
    var isLoading = false
    var isSaving = false
    var error: APIError?
    
    // Create result alert
    var lastCreateResult: BalanceResponse?
    var showCreateResult = false
    
    private let apiService = APIService.shared
    
    // MARK: - Actions
    
    func loadBalances() async {
        guard !isLoading else { return }
        isLoading = true
        error = nil
        
        do {
            balances = try await apiService.fetchBalances()
        } catch {
            self.error = error as? APIError ?? .unknown
        }
        
        isLoading = false
    }
    
    func createBalance(_ input: BalanceInput) async -> Bool {
        isSaving = true
        defer { isSaving = false }
        
        do {
            let response = try await apiService.createBalance(input)
            lastCreateResult = response
            showCreateResult = true
            await loadBalances()
            return true
        } catch {
            self.error = error as? APIError ?? .unknown
            return false
        }
    }
    
    func deleteBalance(id: String) async -> Bool {
        do {
            try await apiService.deleteBalance(id: id)
            balances.removeAll { $0.id == id }
            return true
        } catch {
            self.error = error as? APIError ?? .unknown
            return false
        }
    }
    
    // MARK: - Helpers
    
    var createResultTitle: String {
        guard let result = lastCreateResult else { return "" }
        return result.reconciled ? "✅ Reconciled" : "⚠️ Not Reconciled"
    }
    
    var createResultMessage: String {
        guard let result = lastCreateResult else { return "" }
        let cadFormatter = NumberFormatter()
        cadFormatter.numberStyle = .currency
        cadFormatter.currencyCode = "CAD"
        let rmbFormatter = NumberFormatter()
        rmbFormatter.numberStyle = .currency
        rmbFormatter.currencyCode = "CNY"
        let cadOff = cadFormatter.string(from: NSNumber(value: result.cadOffAmount)) ?? "$\(result.cadOffAmount)"
        let rmbOff = rmbFormatter.string(from: NSNumber(value: result.rmbOffAmount)) ?? "¥\(result.rmbOffAmount)"
        return "CAD off by \(cadOff)\nRMB off by \(rmbOff)"
    }
}
