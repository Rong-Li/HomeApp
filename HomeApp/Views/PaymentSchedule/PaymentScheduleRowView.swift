//
//  PaymentScheduleRowView.swift
//  HomeApp
//
//  Family Expense Tracker
//

import SwiftUI

struct PaymentScheduleRowView: View {
    let schedule: PaymentSchedule
    
    var body: some View {
        HStack(spacing: 14) {
            // Category icon
            ZStack {
                Circle()
                    .fill(schedule.category.color.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: schedule.category.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(schedule.category.color)
            }
            
            // Name and frequency
            VStack(alignment: .leading, spacing: 4) {
                Text(schedule.name)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    Image(systemName: schedule.frequency.icon)
                        .font(.system(size: 10, weight: .medium))
                    Text(schedule.frequencyLabel)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                }
                .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Amount
            Text(schedule.formattedAmount)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(schedule.transactionType == .credit ? .green : .primary)
        }
        .padding(.vertical, 4)
    }
}
