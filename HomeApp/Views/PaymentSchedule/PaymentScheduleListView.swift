//
//  PaymentScheduleListView.swift
//  HomeApp
//
//  Family Expense Tracker
//

import SwiftUI

struct PaymentScheduleListView: View {
    @State var viewModel: PaymentScheduleViewModel
    @State private var showAddForm = false
    @State private var scheduleToEdit: PaymentSchedule?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading && viewModel.schedules.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = viewModel.error, viewModel.schedules.isEmpty {
                    ErrorStateView(message: error.localizedDescription) {
                        Task { await viewModel.loadSchedules() }
                    }
                } else if viewModel.schedules.isEmpty {
                    EmptyStateView(
                        icon: "calendar.badge.plus",
                        title: "No Scheduled Payments",
                        subtitle: "Tap + to create your first schedule"
                    )
                } else {
                    scheduleList
                }
            }
            .navigationTitle("Payment Schedules")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddForm = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(Color.accentColor)
                    }
                }
            }
            .refreshable {
                await viewModel.loadSchedules()
            }
            .sheet(isPresented: $showAddForm) {
                PaymentScheduleFormView(viewModel: viewModel)
            }
            .sheet(item: $scheduleToEdit) { schedule in
                PaymentScheduleFormView(viewModel: viewModel, schedule: schedule)
            }
        }
        .task {
            if viewModel.schedules.isEmpty {
                await viewModel.loadSchedules()
            }
        }
    }
    
    private var scheduleList: some View {
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
