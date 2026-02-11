//
//  PaymentScheduleSnippetView.swift
//  HomeApp
//
//  Family Expense Tracker
//

import SwiftUI

struct PaymentScheduleSnippetView: View {
    @Bindable var viewModel: PaymentScheduleViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var showAddForm = false
    @State private var scheduleToEdit: PaymentSchedule?
    
    private var totalMonthly: Decimal {
        viewModel.schedules.reduce(Decimal.zero) { total, schedule in
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
                if viewModel.isLoading && viewModel.schedules.isEmpty {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else if viewModel.schedules.isEmpty {
                    Spacer()
                    EmptyStateView(
                        icon: "calendar.badge.plus",
                        title: "No Schedules",
                        subtitle: "Tap + to create your first schedule"
                    )
                    Spacer()
                } else {
                    List {
                        ForEach(viewModel.schedules) { schedule in
                            Button {
                                scheduleToEdit = schedule
                            } label: {
                                PaymentScheduleRowView(schedule: schedule)
                            }
                            .buttonStyle(.plain)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    Task {
                                        _ = await viewModel.deleteSchedule(id: schedule.id)
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Scheduled Payments")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showAddForm = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(Color.accentColor)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .sheet(isPresented: $showAddForm) {
                PaymentScheduleFormView(viewModel: viewModel)
            }
            .sheet(item: $scheduleToEdit) { schedule in
                PaymentScheduleFormView(viewModel: viewModel, schedule: schedule)
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
                Text("\(viewModel.schedules.count)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.accentColor)
                Text(viewModel.schedules.count == 1 ? "Schedule" : "Schedules")
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
