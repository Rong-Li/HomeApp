//
//  TransactionFilterSheet.swift
//  HomeApp
//
//  Family Expense Tracker
//

import SwiftUI

struct TransactionFilterSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var filters: TransactionFilters
    
    @State private var localFilters: TransactionFilters
    @State private var minAmountText: String = ""
    @State private var maxAmountText: String = ""
    
    init(filters: Binding<TransactionFilters>) {
        _filters = filters
        _localFilters = State(initialValue: filters.wrappedValue)
        _minAmountText = State(initialValue: filters.wrappedValue.minAmount.map { String(describing: $0) } ?? "")
        _maxAmountText = State(initialValue: filters.wrappedValue.maxAmount.map { String(describing: $0) } ?? "")
    }
    
    var body: some View {
        NavigationStack {
            filterForm
                .navigationTitle("Filters")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Clear") {
                            localFilters.clear()
                            minAmountText = ""
                            maxAmountText = ""
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Apply") {
                            localFilters.minAmount = Decimal(string: minAmountText)
                            localFilters.maxAmount = Decimal(string: maxAmountText)
                            filters = localFilters
                            dismiss()
                        }
                        .fontWeight(.semibold)
                    }
                }
        }
        .presentationDetents([.medium, .large])
    }
    
    private var filterForm: some View {
        Form {
            transactionTypeSection
            hasReceiptSection
            recurringPaymentSection
            amountRangeSection
            categorySection
        }
    }
    
    private var categorySection: some View {
        Section("Category") {
            Button {
                localFilters.selectedCategory = nil
            } label: {
                HStack {
                    Text("All Categories")
                    Spacer()
                    if localFilters.selectedCategory == nil {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.tint)
                    }
                }
            }
            .foregroundStyle(.primary)
            
            ForEach(Category.allCases) { category in
                Button {
                    localFilters.selectedCategory = category
                } label: {
                    HStack {
                        Image(systemName: category.icon)
                            .foregroundStyle(category.color)
                            .frame(width: 24)
                        Text(category.displayName)
                        Spacer()
                        if localFilters.selectedCategory == category {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.tint)
                        }
                    }
                }
                .foregroundStyle(.primary)
            }
        }
    }
    
    private var transactionTypeSection: some View {
        Section("Transaction Type") {
            Picker("Type", selection: $localFilters.transactionType) {
                Text("All").tag(TransactionType?.none)
                Text("Credit (Income)").tag(TransactionType?.some(.credit))
                Text("Debit (Expense)").tag(TransactionType?.some(.debit))
            }
            .pickerStyle(.segmented)
        }
    }
    
    private var hasReceiptSection: some View {
        Section("Has Receipt") {
            Picker("Receipt", selection: $localFilters.hasReceipt) {
                Text("All").tag(Bool?.none)
                Text("Yes").tag(Bool?.some(true))
                Text("No").tag(Bool?.some(false))
            }
            .pickerStyle(.segmented)
        }
    }
    
    private var recurringPaymentSection: some View {
        Section("Recurring Payment") {
            Picker("Recurring", selection: $localFilters.recurringPayment) {
                Text("All").tag(Bool?.none)
                Text("Yes").tag(Bool?.some(true))
                Text("No").tag(Bool?.some(false))
            }
            .pickerStyle(.segmented)
        }
    }
    
    private var amountRangeSection: some View {
        Section("Amount Range") {
            HStack {
                TextField("Min", text: $minAmountText)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
                Text("to")
                    .foregroundStyle(.secondary)
                TextField("Max", text: $maxAmountText)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
            }
        }
    }
}

#Preview {
    TransactionFilterSheet(filters: .constant(TransactionFilters()))
}
