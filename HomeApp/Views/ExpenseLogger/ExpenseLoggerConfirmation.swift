//
//  ExpenseLoggerConfirmation.swift
//  HomeApp
//
//  Family Expense Tracker - Action Button Confirmation View
//  Displays confirmation after expense is logged
//

import SwiftUI

/// Confirmation view shown after successfully logging an expense
struct ExpenseLoggerConfirmation: View {
    var message: String = "Expense logged successfully"
    
    var body: some View {
        VStack(spacing: 20) {
            // Success Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.green.opacity(0.2), Color.green.opacity(0.08)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(.green)
                    .symbolEffect(.bounce, value: message)
            }
            
            // Message
            VStack(spacing: 6) {
                Text("Logged")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .tracking(1.5)
                
                Text(message)
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .padding(.horizontal, 20)
    }
}

#Preview("Success - Expense") {
    ExpenseLoggerConfirmation(message: "Groceries -$42.50")
}

#Preview("Success - Income") {
    ExpenseLoggerConfirmation(message: "Salary +$3,500.00")
}
