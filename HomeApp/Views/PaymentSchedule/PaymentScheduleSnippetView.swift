//
//  PaymentScheduleSnippetView.swift
//  HomeApp
//
//  Family Expense Tracker
//

import SwiftUI

struct PaymentScheduleSnippetView: View {
    let schedules: [PaymentSchedule]
    let onManage: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    private var totalMonthly: Decimal {
        schedules.reduce(Decimal.zero) { total, schedule in
            let multiplier: Decimal
            switch schedule.frequency {
            case .weekly: multiplier = 4
            case .biweekly: multiplier = 2
            case .monthly: multiplier = 1
            }
            let amount = schedule.transactionType == .credit ? -schedule.amount : schedule.amount
            return total + (amount * multiplier)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Monthly total card
                monthlySummaryCard
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                // Schedule list
                if schedules.isEmpty {
                    Spacer()
                    EmptyStateView(
                        icon: "calendar.badge.plus",
                        title: "No Schedules",
                        subtitle: "Add your first payment schedule"
                    )
                    Spacer()
                } else {
                    List {
                        ForEach(schedules.prefix(5)) { schedule in
                            PaymentScheduleRowView(schedule: schedule)
                        }
                        
                        if schedules.count > 5 {
                            HStack {
                                Spacer()
                                Text("+\(schedules.count - 5) more")
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundStyle(.secondary)
                                Spacer()
                            }
                            .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(.plain)
                }
                
                // Manage button
                Button {
                    dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onManage()
                    }
                } label: {
                    HStack(spacing: 8) {
                        Text("Manage All")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(
                                LinearGradient(
                                    colors: [Color.accentColor, Color.accentColor.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                }
                .padding(.horizontal)
                .padding(.bottom, 16)
            }
            .navigationTitle("Scheduled Payments")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
    
    private var monthlySummaryCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Est. Monthly Total")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                
                let formatter = NumberFormatter()
                let _ = { formatter.numberStyle = .currency; formatter.currencyCode = "CAD" }()
                Text(formatter.string(from: totalMonthly as NSDecimalNumber) ?? "$0.00")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(schedules.count)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.accentColor)
                Text(schedules.count == 1 ? "Schedule" : "Schedules")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }
}
