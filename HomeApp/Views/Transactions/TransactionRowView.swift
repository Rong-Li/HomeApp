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
        HStack(spacing: 14) {
            // Category Icon with gradient background
            Image(systemName: transaction.category.icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(transaction.category.color)
                .frame(width: 44, height: 44)
                .background(
                    LinearGradient(
                        colors: [
                            transaction.category.color.opacity(0.2),
                            transaction.category.color.opacity(0.08)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Circle())
            
            // Category, Merchant & Date
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.category.displayName)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                
                if let subtitle = transaction.displaySubtitle {
                    Text(subtitle)
                        .font(.system(size: 14, design: .rounded))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                HStack(spacing: 4) {
                    Text(transaction.formattedDateTime)
                        .font(.system(size: 12, design: .rounded))
                        .foregroundStyle(.tertiary)
                    
                    if transaction.hasReceipt {
                        Image(systemName: "paperclip")
                            .font(.system(size: 11))
                            .foregroundStyle(.tertiary)
                    }
                }
            }
            
            Spacer()
            
            // Amount
            Text(transaction.formattedAmount)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(transaction.isCredit ? .green : .primary)
        }
        .padding(.vertical, 10)
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
            receiptId: "abc",
            recurringPayment: nil
        ))
        
        TransactionRowView(transaction: Transaction(
            id: "2",
            amount: 500.00,
            category: .transportation,
            transactionType: .credit,
            createdAt: Date(),
            merchant: nil,
            description: nil,
            receiptId: nil,
            recurringPayment: nil
        ))
    }
}
