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
    @State private var cashViewModel = CashViewModel()
    @State private var showCashSnippet = false
    @State private var balanceViewModel = BalanceViewModel()
    @State private var showBalanceSnippet = false
    
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
                PaymentScheduleSnippetView(viewModel: scheduleViewModel)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showCashSnippet) {
                CashSnippetView(viewModel: cashViewModel)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showBalanceSnippet) {
                BalanceSnippetView(viewModel: balanceViewModel)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
        .task {
            await viewModel.loadTransactions()
            await scheduleViewModel.loadSchedules()
            await cashViewModel.loadStatus()
            await balanceViewModel.loadBalances()
        }
        .onChange(of: viewModel.selectedTimeRange) {
            Task { await viewModel.loadTransactions() }
        }
    }
    
    private var mainContent: some View {
        VStack(spacing: 0) {
            // Control header
            VStack(spacing: 10) {
                // Top row: Search bar + Filter
                HStack(spacing: 8) {
                    // Search bar
                    HStack(spacing: 6) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.quaternary)
                        TextField("Search", text: $viewModel.searchText)
                            .font(.system(size: 14, design: .rounded))
                            .textFieldStyle(.plain)
                        
                        if !viewModel.searchText.isEmpty {
                            Button {
                                viewModel.searchText = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 13))
                                    .foregroundStyle(.quaternary)
                            }
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(Color(.tertiarySystemFill).opacity(0.8))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    // Filter button next to search
                    filterButton
                }
                
                // Controls row: Time Range (Prominent) | Schedules/Cash
                HStack(spacing: 8) {
                    // Time range selector - made more prominent with a border and background
                    TimeRangePickerView(selectedRange: $viewModel.selectedTimeRange)
                    
                    Spacer()
                    
                    // Cash pill
                    cashPill
                    
                    // Balance pill
                    balancePill
                    
                    // Schedule pill
                    schedulePill
                }
                .padding(.top, 2)
            }
            .padding(.horizontal, 16)
            .padding(.top, 4)
            .padding(.bottom, 12)
            .background(
                Color(.systemBackground)
                    .shadow(.drop(color: .black.opacity(0.04), radius: 4, y: 2))
            )
            
            // Active Filters
            if !viewModel.filters.isEmpty {
                ActiveFilterChipsView(filters: viewModel.filters) {
                    viewModel.filters.clear()
                }
                .padding(.top, 8)
                .padding(.bottom, 4)
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
            HStack(spacing: 5) {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 13, weight: .semibold))
                
                if !viewModel.filters.isEmpty {
                    Text("\(viewModel.filters.activeCount)")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Circle().fill(Color.accentColor))
                }
            }
            .foregroundStyle(.primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.tertiarySystemFill).opacity(0.8))
            )
        }
        .buttonStyle(.plain)
    }
    
    private var cashPill: some View {
        Button {
            showCashSnippet = true
        } label: {
            HStack(spacing: 5) {
                Image(systemName: "dollarsign.circle.fill")
                    .font(.system(size: 13, weight: .semibold))
                
                Text("Cash")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color.green, Color.green.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: Color.green.opacity(0.3), radius: 4, y: 2)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    private var balancePill: some View {
        Button {
            showBalanceSnippet = true
        } label: {
            HStack(spacing: 5) {
                Image(systemName: "book.fill")
                    .font(.system(size: 13, weight: .semibold))
                
                Text("Bal")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color.orange, Color.orange.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: Color.orange.opacity(0.3), radius: 4, y: 2)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    private var schedulePill: some View {
        Button {
            showScheduleSnippet = true
        } label: {
            HStack(spacing: 5) {
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 13, weight: .semibold))
                
                Text(scheduleViewModel.schedules.isEmpty ? "Schedules" : "\(scheduleViewModel.schedules.count)")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color.accentColor, Color.accentColor.opacity(0.85)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: Color.accentColor.opacity(0.3), radius: 4, y: 2)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

#Preview {
    TransactionsView()
}
