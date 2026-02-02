//
//  ActiveFilterChipsView.swift
//  HomeApp
//
//  Family Expense Tracker
//

import SwiftUI

struct ActiveFilterChipsView: View {
    let filters: TransactionFilters
    let onClearAll: () -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                if let category = filters.selectedCategory {
                    FilterChip(label: category.displayName)
                }
                
                if let type = filters.transactionType {
                    FilterChip(label: type.displayName)
                }
                
                if let hasReceipt = filters.hasReceipt {
                    FilterChip(label: hasReceipt ? "Has Receipt" : "No Receipt")
                }
                
                if let recurring = filters.recurringPayment {
                    FilterChip(label: recurring ? "Recurring" : "One-time")
                }
                
                if filters.minAmount != nil || filters.maxAmount != nil {
                    let minStr = filters.minAmount.map { "$\($0)" } ?? ""
                    let maxStr = filters.maxAmount.map { "$\($0)" } ?? ""
                    FilterChip(label: "\(minStr) - \(maxStr)")
                }
                
                Button("Clear", action: onClearAll)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
            .padding(.horizontal)
        }
    }
}

struct FilterChip: View {
    let label: String
    
    var body: some View {
        Text(label)
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.accentColor.opacity(0.15))
            .foregroundStyle(Color.accentColor)
            .clipShape(Capsule())
    }
}

#Preview {
    ActiveFilterChipsView(
        filters: TransactionFilters(selectedCategory: .groceries, transactionType: .debit),
        onClearAll: {}
    )
}
