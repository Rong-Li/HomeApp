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
            Form {
                // Category Section (Single Select)
                Section("Category") {
                    ForEach([Category?.none] + Category.allCases.map { Optional($0) }, id: \.self) { category in
                        Button {
                            localFilters.selectedCategory = category
                        } label: {
                            HStack {
                                if let cat = category {
                                    Image(systemName: cat.icon)
                                        .foregroundStyle(cat.color)
                                        .frame(width: 24)
                                    Text(cat.displayName)
                                } else {
                                    Text("All Categories")
                                }
                                Spacer()
                                if localFilters.selectedCategory == category {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.accentColor)
                                }
                            }
                        }
                        .foregroundStyle(.primary)
                    }
                }
                
                // Transaction Type Section
                Section("Transaction Type") {
                    Picker("Type", selection: $localFilters.transactionType) {
                        Text("All").tag(TransactionType?.none)
                        Text("Credit (Income)").tag(TransactionType?.some(.credit))
                        Text("Debit (Expense)").tag(TransactionType?.some(.debit))
                    }
                    .pickerStyle(.segmented)
                }
                
                // Has Receipt Section
                Section("Has Receipt") {
                    Picker("Receipt", selection: $localFilters.hasReceipt) {
                        Text("All").tag(Bool?.none)
                        Text("Yes").tag(Bool?.some(true))
                        Text("No").tag(Bool?.some(false))
                    }
                    .pickerStyle(.segmented)
                }
                
                // Amount Range Section
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
}

#Preview {
    TransactionFilterSheet(filters: .constant(TransactionFilters()))
}
