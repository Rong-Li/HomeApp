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
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    filterButton
                }
            }
            .searchable(text: $viewModel.searchText, prompt: "Search transactions")
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
        }
        .task {
            await viewModel.loadTransactions()
        }
    }
    
    private var mainContent: some View {
        VStack(spacing: 0) {
            // Time Range Picker
            HStack {
                TimeRangePickerView(selectedRange: $viewModel.selectedTimeRange)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            
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
                    .font(.title3)
                
                if !viewModel.filters.isEmpty {
                    Circle()
                        .fill(Color.accentColor)
                        .frame(width: 8, height: 8)
                        .offset(x: 2, y: -2)
                }
            }
        }
    }
}

#Preview {
    TransactionsView()
}
