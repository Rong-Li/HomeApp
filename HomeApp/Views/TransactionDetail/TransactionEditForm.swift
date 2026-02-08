//
//  TransactionEditForm.swift
//  HomeApp
//
//  Family Expense Tracker
//

import SwiftUI

struct TransactionEditForm: View {
    @Binding var transaction: Transaction
    
    var body: some View {
        VStack(spacing: 20) {
            // Amount Section
            VStack(alignment: .leading, spacing: 8) {
                Text("Amount")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                TextField("Amount", value: $transaction.amount, format: .currency(code: transaction.currency.rawValue))
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
                    .font(.title2)
            }
            
            // Currency Section
            VStack(alignment: .leading, spacing: 8) {
                Text("Currency")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Picker("Currency", selection: $transaction.currency) {
                    ForEach(Currency.allCases, id: \.self) { currency in
                        Text("\(currency.flag) \(currency.rawValue)").tag(currency)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            // Category Section
            VStack(alignment: .leading, spacing: 8) {
                Text("Category")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Picker("Category", selection: $transaction.category) {
                    ForEach(Category.allCases) { category in
                        Label(category.displayName, systemImage: category.icon)
                            .tag(category)
                    }
                }
                .pickerStyle(.menu)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            // Type Section
            VStack(alignment: .leading, spacing: 8) {
                Text("Type")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Picker("Type", selection: $transaction.transactionType) {
                    Text("Credit (Income)").tag(TransactionType.credit)
                    Text("Debit (Expense)").tag(TransactionType.debit)
                }
                .pickerStyle(.segmented)
            }
            
            // Date Section
            VStack(alignment: .leading, spacing: 8) {
                Text("Date")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                DatePicker(
                    "Date",
                    selection: $transaction.createdAt,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .labelsHidden()
            }
            
            // Merchant Section
            VStack(alignment: .leading, spacing: 8) {
                Text("Merchant")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                TextField("Merchant name (optional)", text: Binding(
                    get: { transaction.merchant ?? "" },
                    set: { transaction.merchant = $0.isEmpty ? nil : $0 }
                ))
                .textFieldStyle(.roundedBorder)
            }
            
            // Description Section
            VStack(alignment: .leading, spacing: 8) {
                Text("Description")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                TextField("Description (optional)", text: Binding(
                    get: { transaction.description ?? "" },
                    set: { transaction.description = $0.isEmpty ? nil : $0 }
                ), axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(3...6)
            }
            
            // Recurring Payment Section
            VStack(alignment: .leading, spacing: 8) {
                Text("Recurring Payment")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Toggle("Recurring", isOn: Binding(
                    get: { transaction.recurringPayment ?? false },
                    set: { transaction.recurringPayment = $0 }
                ))
            }
        }
    }
}

#Preview {
    TransactionEditForm(transaction: .constant(Transaction(
        id: "1",
        amount: 85.50,
        category: .groceries,
        transactionType: .debit,
        currency: .cad,
        createdAt: Date(),
        merchant: "Costco",
        description: nil,
        recurringPayment: nil,
        postalCode: nil
    )))
    .padding()
}
