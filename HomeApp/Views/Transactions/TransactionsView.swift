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
            // Control header
            VStack(spacing: 10) {
                // Search bar - full width
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
                
                // Controls row: Time Range | Filter | Schedules
                HStack(spacing: 8) {
                    // Time range selector
                    TimeRangePickerView(selectedRange: $viewModel.selectedTimeRange)
                    
                    // Filter button
                    filterButton
                    
                    Spacer()
                    
                    // Schedule pill
                    schedulePill
                }
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
                    .font(.system(size: 12, weight: .semibold))
                Text("Filters")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                
                if !viewModel.filters.isEmpty {
                    Text("\(viewModel.filters.activeCount)")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(Color.accentColor))
                }
            }
            .foregroundStyle(.primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(
                Capsule()
                    .fill(Color(.tertiarySystemFill))
            )
        }
        .buttonStyle(.plain)
    }
    
    private var schedulePill: some View {
        Button {
            showScheduleSnippet = true
        } label: {
            HStack(spacing: 5) {
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 12, weight: .semibold))
                
                Text(scheduleViewModel.schedules.isEmpty ? "Schedules" : "\(scheduleViewModel.schedules.count)")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
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
