//
//  TransactionsView.swift
//  HomeApp
//
//  Family Expense Tracker
//

import SwiftUI

struct TransactionsView: View {
    @State private var viewModel = TransactionsViewModel()
    @State private var networkMonitor = NetworkMonitor.shared
    @State private var showExpenseLogger = false
    @State private var showFilters = false
    @State private var scheduleViewModel = PaymentScheduleViewModel()
    @State private var showScheduleSnippet = false
    @State private var showScheduleManagement = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                if !networkMonitor.isConnected {
                    OfflineStateView()
                } else {
                    mainContent
                }
                
                // FAB
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        FloatingActionButton(isDisabled: !networkMonitor.isConnected) {
                            showExpenseLogger = true
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Transactions")
            .refreshable {
                await viewModel.refresh()
            }
            .sheet(isPresented: $showExpenseLogger) {
                ExpenseLoggerView {
                    Task { await viewModel.loadTransactions() }
                }
            }
            .sheet(isPresented: $showFilters) {
                TransactionFilterSheet(filters: $viewModel.filters)
            }
            .sheet(isPresented: $showScheduleSnippet) {
                PaymentScheduleSnippetView(
                    schedules: scheduleViewModel.schedules,
                    onManage: { showScheduleManagement = true }
                )
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
            .fullScreenCover(isPresented: $showScheduleManagement) {
                PaymentScheduleListView(viewModel: scheduleViewModel)
            }
        }
        .task {
            await viewModel.loadTransactions()
            await scheduleViewModel.loadSchedules()
        }
        .onChange(of: viewModel.selectedTimeRange) {
            Task { await viewModel.loadTransactions() }
        }
    }
    
    private var mainContent: some View {
        VStack(spacing: 0) {
            // Search bar & Filter - top row
            HStack(spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.tertiary)
                    TextField("Search", text: $viewModel.searchText)
                        .font(.system(size: 15, design: .rounded))
                        .textFieldStyle(.plain)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                
                filterButton
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            // Time Range Picker + Schedule Pill
            HStack(spacing: 10) {
                TimeRangePickerView(selectedRange: $viewModel.selectedTimeRange)
                
                Spacer()
                
                schedulePill
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
            
            // Active Filters
            if !viewModel.filters.isEmpty {
                ActiveFilterChipsView(filters: viewModel.filters) {
                    viewModel.filters.clear()
                }
                .padding(.bottom, 8)
            }
            
            // Content
            if viewModel.isLoading && viewModel.displayedTransactions.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = viewModel.error {
                ErrorStateView(message: error.localizedDescription) {
                    Task { await viewModel.loadTransactions() }
                }
            } else if viewModel.filteredTransactions.isEmpty {
                EmptyStateView(
                    icon: "tray.fill",
                    title: "No transactions",
                    subtitle: "Tap + to log your first expense"
                )
            } else {
                transactionList
            }
        }
    }
    
    private var transactionList: some View {
        List {
            ForEach(viewModel.displayedTransactions) { transaction in
                NavigationLink(value: transaction) {
                    TransactionRowView(transaction: transaction)
                }
            }
            
            // Load more trigger
            if viewModel.canLoadMore {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .onAppear {
                    viewModel.loadMore()
                }
            }
        }
        .listStyle(.plain)
        .navigationDestination(for: Transaction.self) { transaction in
            TransactionDetailView(transaction: transaction, onUpdate: {
                Task { await viewModel.loadTransactions() }
            })
        }
    }
    
    private var filterButton: some View {
        Button {
            showFilters = true
        } label: {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .font(.system(size: 18, weight: .medium))
                    .frame(width: 40, height: 40)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                
                if !viewModel.filters.isEmpty {
                    Circle()
                        .fill(Color.accentColor)
                        .frame(width: 8, height: 8)
                        .offset(x: 4, y: -4)
                }
            }
        }
        .buttonStyle(.plain)
    }
    
    private var schedulePill: some View {
        Button {
            showScheduleSnippet = true
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 13, weight: .semibold))
                
                if scheduleViewModel.schedules.isEmpty {
                    Text("Schedules")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                } else {
                    Text("\(scheduleViewModel.schedules.count)")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                }
            }
            .foregroundStyle(Color.accentColor)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Color.accentColor.opacity(0.12))
                    .overlay(
                        Capsule()
                            .strokeBorder(Color.accentColor.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

#Preview {
    TransactionsView()
}
