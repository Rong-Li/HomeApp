//
//  TransactionRowView.swift
//  HomeApp
//
//  Family Expense Tracker
//

import SwiftUI

struct TransactionRowView: View {
    let transaction: Transaction
    
    var body: some View {
        HStack(spacing: 12) {
            // Category Icon
            Image(systemName: transaction.category.icon)
                .font(.title2)
                .foregroundStyle(transaction.category.color)
                .frame(width: 40, height: 40)
                .background(transaction.category.color.opacity(0.15))
                .clipShape(Circle())
            
            // Category, Merchant & Date
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.category.displayName)
                    .font(.headline)
                
                if let subtitle = transaction.displaySubtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                HStack(spacing: 4) {
                    Text(transaction.formattedDateTime)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    if transaction.hasReceipt {
                        Image(systemName: "paperclip")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Amount
            Text(transaction.formattedAmount)
                .font(.headline)
                .foregroundStyle(transaction.isCredit ? .green : .red)
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}

#Preview {
    List {
        TransactionRowView(transaction: Transaction(
            id: "1",
            amount: 85.50,
            category: .groceries,
            transactionType: .debit,
            createdAt: Date(),
            merchant: "Costco",
            description: nil,
            receiptId: "abc"
        ))
        
        TransactionRowView(transaction: Transaction(
            id: "2",
            amount: 500.00,
            category: .transportation,
            transactionType: .credit,
            createdAt: Date(),
            merchant: nil,
            description: nil,
            receiptId: nil
        ))
    }
}
