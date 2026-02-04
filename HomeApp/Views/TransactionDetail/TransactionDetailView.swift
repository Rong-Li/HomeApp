//
//  TransactionDetailView.swift
//  HomeApp
//
//  Family Expense Tracker
//

import SwiftUI

struct TransactionDetailView: View {
    @State private var viewModel: TransactionDetailViewModel
    @State private var isEditing = false
    @State private var editingTransaction: Transaction?
    @State private var showDeleteConfirmation = false
    @State private var showDiscardAlert = false
    @Environment(\.dismiss) private var dismiss
    
    var onUpdate: (() -> Void)?
    
    init(transaction: Transaction, onUpdate: (() -> Void)? = nil) {
        _viewModel = State(initialValue: TransactionDetailViewModel(transaction: transaction))
        self.onUpdate = onUpdate
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if isEditing, let binding = Binding($editingTransaction) {
                    TransactionEditForm(transaction: binding)
                } else {
                    headerSection
                    detailsSection
                    receiptSection
                    deleteSection
                }
            }
            .padding()
        }
        .navigationTitle("Transaction")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(isEditing)
        .toolbar {
            if isEditing {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        if editingTransaction != viewModel.transaction {
                            showDiscardAlert = true
                        } else {
                            isEditing = false
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        Task { await saveChanges() }
                    }
                    .fontWeight(.semibold)
                    .disabled(viewModel.isSaving)
                }
            } else {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Edit") {
                        editingTransaction = viewModel.transaction
                        isEditing = true
                    }
                }
            }
        }
        .alert("Discard Changes?", isPresented: $showDiscardAlert) {
            Button("Keep Editing", role: .cancel) { }
            Button("Discard", role: .destructive) {
                isEditing = false
            }
        }
        .alert("Delete Transaction?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                Task { await deleteTransaction() }
            }
        } message: {
            Text("This action cannot be undone.")
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Icon with gradient background
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                viewModel.transaction.category.color.opacity(0.25),
                                viewModel.transaction.category.color.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Image(systemName: viewModel.transaction.category.icon)
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundStyle(viewModel.transaction.category.color)
            }
            
            Text(viewModel.transaction.formattedAmount)
                .font(.system(size: 38, weight: .bold, design: .rounded))
                .foregroundStyle(viewModel.transaction.isCredit ? .green : .primary)
            
            Text(viewModel.transaction.category.displayName)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }
    
    // MARK: - Details Section
    
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("DETAILS")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.bottom, 8)
            
            GroupBox {
                VStack(spacing: 0) {
                    DetailRow(label: "Type", value: viewModel.transaction.transactionType.displayName)
                    Divider()
                    DetailRow(label: "Date", value: viewModel.formattedFullDateTime)
                    
                    if let merchant = viewModel.transaction.merchant {
                        Divider()
                        DetailRow(label: "Merchant", value: merchant)
                    }
                    
                    if let description = viewModel.transaction.description {
                        Divider()
                        DetailRow(label: "Description", value: description)
                    }
                    
                    if let recurring = viewModel.transaction.recurringPayment {
                        Divider()
                        DetailRow(label: "Recurring", value: recurring ? "Yes" : "No")
                    }
                }
            }
        }
    }
    
    // MARK: - Receipt Section
    
    private var receiptSection: some View {
        ReceiptSectionView(viewModel: viewModel)
    }
    
    // MARK: - Delete Section
    
    private var deleteSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(role: .destructive) {
                showDeleteConfirmation = true
            } label: {
                HStack {
                    Image(systemName: "trash")
                    Text("Delete Transaction")
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
            .buttonStyle(.bordered)
            .tint(.red)
        }
    }
    
    // MARK: - Actions
    
    private func saveChanges() async {
        guard let updated = editingTransaction else { return }
        
        do {
            try await viewModel.saveTransaction(updated)
            // Only set isEditing = false; don't nil out editingTransaction
            // Setting editingTransaction = nil causes a crash because SwiftUI's
            // Binding force-unwrapping tries to access it during view update
            isEditing = false
            onUpdate?()
        } catch {
            viewModel.error = "Failed to save changes"
        }
    }
    
    private func deleteTransaction() async {
        do {
            try await viewModel.deleteTransaction()
            
            // Haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            onUpdate?()
            dismiss()
        } catch {
            viewModel.error = "Failed to delete transaction"
        }
    }
}

// MARK: - Detail Row

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
        }
        .padding(.vertical, 12)
    }
}

#Preview {
    NavigationStack {
        TransactionDetailView(
            transaction: Transaction(
                id: "1",
                amount: 85.50,
                category: .groceries,
                transactionType: .debit,
                createdAt: Date(),
                merchant: "Costco",
                description: "Weekly groceries",
                receiptId: nil,
                recurringPayment: nil
            )
        )
    }
}
