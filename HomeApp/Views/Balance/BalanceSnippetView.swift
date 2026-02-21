//
//  BalanceSnippetView.swift
//  HomeApp
//
//  Family Expense Tracker
//

import SwiftUI

struct BalanceSnippetView: View {
    @Bindable var viewModel: BalanceViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var showAddForm = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if viewModel.isLoading && viewModel.balances.isEmpty {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else if viewModel.balances.isEmpty {
                    Spacer()
                    EmptyStateView(
                        icon: "book.fill",
                        title: "No Balances",
                        subtitle: "Tap + to record your first balance"
                    )
                    Spacer()
                } else {
                    balanceList
                }
            }
            .navigationTitle("Balances")
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
                BalanceAddFormView(viewModel: viewModel)
            }
            .alert(viewModel.createResultTitle, isPresented: $viewModel.showCreateResult) {
                Button("OK") {}
            } message: {
                Text(viewModel.createResultMessage)
            }
        }
    }
    
    // MARK: - Balance List
    
    private var balanceList: some View {
        List {
            ForEach(viewModel.balances) { balance in
                VStack(alignment: .leading, spacing: 6) {
                    // Top row: date + reconciled badge
                    HStack {
                        Text(balance.formattedDate)
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(systemName: balance.reconciled ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                .font(.system(size: 12))
                            Text(balance.reconciled ? "Reconciled" : balance.formattedCADOff)
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                        }
                        .foregroundStyle(balance.reconciled ? Color.green : Color.orange)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(balance.reconciled ? Color.green.opacity(0.12) : Color.orange.opacity(0.12))
                        )
                    }
                    
                    // Bottom row: CAD + RMB
                    HStack(spacing: 12) {
                        Text(balance.formattedCAD)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                        
                        Text(balance.formattedRMB)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
            .onDelete { indexSet in
                for index in indexSet {
                    let balance = viewModel.balances[index]
                    Task { _ = await viewModel.deleteBalance(id: balance.id) }
                }
            }
        }
        .listStyle(.plain)
    }
}
