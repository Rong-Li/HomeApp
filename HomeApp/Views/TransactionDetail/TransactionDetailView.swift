//
//  TransactionDetailView.swift
//  HomeApp
//
//  Family Expense Tracker
//

import SwiftUI
import MapKit

struct TransactionDetailView: View {
    @State private var viewModel: TransactionDetailViewModel
    @State private var isEditing = false
    @State private var editingTransaction: Transaction?
    @State private var showDeleteConfirmation = false
    @State private var showDeleteSuccess = false
    @State private var showDiscardAlert = false
    @Environment(\.dismiss) private var dismiss
    
    var onUpdate: (() -> Void)?
    
    init(transaction: Transaction, onUpdate: (() -> Void)? = nil) {
        _viewModel = State(initialValue: TransactionDetailViewModel(transaction: transaction))
        self.onUpdate = onUpdate
    }
    
    var body: some View {
        ZStack {
            if showDeleteSuccess {
                SuccessView(message: "Transaction deleted", subtitle: nil)
                    .transition(.scale.combined(with: .opacity))
                    .onAppear {
                        Task {
                            try? await Task.sleep(for: .seconds(1.5))
                            onUpdate?()
                            dismiss()
                        }
                    }
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        if isEditing, let binding = Binding($editingTransaction) {
                            TransactionEditForm(transaction: binding)
                        } else {
                            headerSection
                            if viewModel.transaction.postalCode != nil {
                                locationSection
                            }
                            detailsSection
                            deleteSection
                        }
                    }
                    .padding()
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showDeleteSuccess)
        .navigationTitle("Transaction")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(isEditing || showDeleteSuccess)
        .toolbar {
            if !showDeleteSuccess {
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
        VStack(spacing: 12) {
            // Icon with modern gradient and shadow
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                viewModel.transaction.category.color.opacity(0.2),
                                viewModel.transaction.category.color.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 72, height: 72)
                    .shadow(color: viewModel.transaction.category.color.opacity(0.2), radius: 12, y: 4)
                
                Image(systemName: viewModel.transaction.category.icon)
                    .font(.system(size: 32, weight: .medium))
                    .foregroundStyle(viewModel.transaction.category.color)
            }
            
            Text(viewModel.transaction.formattedAmount)
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .foregroundStyle(viewModel.transaction.isCredit ? Color(red: 0.2, green: 0.8, blue: 0.4) : .primary)
                .contentTransition(.numericText())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
    
    // MARK: - Details Section
    
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("DETAILS")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary)
                .tracking(0.5)
            
            VStack(spacing: 0) {
                DetailRow(label: "Category", value: viewModel.transaction.category.displayName, icon: "tag.fill")
                DetailRow(label: "Date", value: viewModel.formattedFullDateTime, icon: "calendar")
                
                if let merchant = viewModel.transaction.merchant {
                    DetailRow(label: "Merchant", value: merchant, icon: "storefront.fill")
                }
                
                if let description = viewModel.transaction.description {
                    DetailRow(label: "Note", value: description, icon: "text.alignleft")
                }
                
                if let recurring = viewModel.transaction.recurringPayment, recurring {
                    DetailRow(label: "Recurring", value: "Yes", icon: "repeat")
                }
            }
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
    }
    
    // MARK: - Location Section
    
    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("LOCATION")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary)
                .tracking(0.5)
            
            PostalCodeMapView(postalCode: viewModel.transaction.postalCode ?? "")
                .frame(height: 140)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.08), radius: 8, y: 2)
        }
    }
    
    // MARK: - Delete Section
    
    private var deleteSection: some View {
        Button(role: .destructive) {
            showDeleteConfirmation = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "trash")
                    .font(.system(size: 14, weight: .medium))
                Text("Delete Transaction")
                    .font(.system(size: 15, weight: .medium))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.red.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
        }
        .foregroundStyle(.red)
        .padding(.top, 8)
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
            
            await MainActor.run {
                // Haptic feedback
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                
                showDeleteSuccess = true
            }
        } catch {
            await MainActor.run {
                viewModel.error = "Failed to delete transaction"
            }
        }
    }
}

// MARK: - Detail Row

struct DetailRow: View {
    let label: String
    let value: String
    var icon: String? = nil
    
    var body: some View {
        HStack(spacing: 12) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    .frame(width: 20)
            }
            
            Text(label)
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
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
                currency: .cad,
                createdAt: Date(),
                merchant: "Costco",
                description: "Weekly groceries",
                recurringPayment: nil,
                postalCode: nil
            )
        )
    }
}

