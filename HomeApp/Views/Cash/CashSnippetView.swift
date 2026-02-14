//
//  CashSnippetView.swift
//  HomeApp
//
//  Family Expense Tracker
//

import SwiftUI

struct CashSnippetView: View {
    @Bindable var viewModel: CashViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var showResetConfirmation = false
    @FocusState private var isAmountFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Balance card
                balanceCard
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                // Add transaction section
                addTransactionSection
                    .padding(.horizontal)
                    .padding(.top, 12)
                
                // Transaction history
                if viewModel.isLoading && viewModel.transactions.isEmpty {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else if viewModel.transactions.isEmpty {
                    Spacer()
                    EmptyStateView(
                        icon: "banknote",
                        title: "No Transactions",
                        subtitle: "Add your first cash transaction above"
                    )
                    Spacer()
                } else {
                    transactionList
                }
            }
            .navigationTitle("Cash")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showResetConfirmation = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.counterclockwise.circle.fill")
                            Text("Reset")
                                .font(.system(.body, design: .rounded, weight: .semibold))
                        }
                        .foregroundStyle(.red.opacity(0.8))
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
            .alert("Reset Cash Data", isPresented: $showResetConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    Task { _ = await viewModel.resetData() }
                }
            } message: {
                Text("This will delete all transactions and reset the balance to $0. This cannot be undone.")
            }
        }
    }
    
    // MARK: - Balance Card
    
    private var balanceCard: some View {
        VStack(spacing: 6) {
            Text("Balance")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
            
            Text(viewModel.formattedBalance)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(viewModel.balance >= 0 ? Color.primary : Color.red)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }
    
    // MARK: - Add Transaction
    
    private var addTransactionSection: some View {
        VStack(spacing: 10) {
            // Amount input
            HStack(spacing: 8) {
                Text("$")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
                
                TextField("0.00", text: $viewModel.amountText)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.plain)
                    .focused($isAmountFocused)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.tertiarySystemFill))
            )
            
            // Credit/Debit toggle + Submit
            HStack(spacing: 10) {
                // Segmented toggle
                Picker("Type", selection: $viewModel.selectedType) {
                    Text("Credit").tag(TransactionType.credit)
                    Text("Debit").tag(TransactionType.debit)
                }
                .pickerStyle(.segmented)
                
                // Submit button
                Button {
                    isAmountFocused = false
                    Task { _ = await viewModel.addTransaction() }
                } label: {
                    Group {
                        if viewModel.isSaving {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "plus")
                                .font(.system(size: 14, weight: .bold))
                        }
                    }
                    .frame(width: 40, height: 32)
                    .foregroundStyle(.white)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.accentColor)
                    )
                }
                .disabled(viewModel.amountText.isEmpty || viewModel.isSaving)
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }
    
    // MARK: - Transaction List
    
    private var transactionList: some View {
        List {
            ForEach(viewModel.transactions) { transaction in
                HStack {
                    Text(transaction.formattedAmount)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(transaction.type == .credit ? Color.green : Color.primary)
                    
                    Spacer()
                    
                    Text(transaction.formattedTimestamp)
                        .font(.system(size: 13, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 2)
            }
        }
        .listStyle(.plain)
    }
}
