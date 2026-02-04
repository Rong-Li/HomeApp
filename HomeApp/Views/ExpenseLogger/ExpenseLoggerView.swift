//
//  ExpenseLoggerView.swift
//  HomeApp
//
//  Family Expense Tracker - Modern Minimalistic Design
//

import SwiftUI

struct ExpenseLoggerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = ExpenseLoggerViewModel()
    @FocusState private var isAmountFocused: Bool
    var onSuccess: (() -> Void)?
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.showSuccess {
                    SuccessView(message: viewModel.successMessage)
                        .transition(.scale.combined(with: .opacity))
                        .onAppear {
                            Task {
                                try? await Task.sleep(for: .seconds(1.5))
                                onSuccess?()
                                dismiss()
                            }
                        }
                } else {
                    formContent
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.showSuccess)
            .navigationTitle("Log Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.system(size: 16, design: .rounded))
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .interactiveDismissDisabled(viewModel.isSubmitting)
    }
    
    private var formContent: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 28) {
                    // Amount Input
                    amountSection
                    
                    // Type Toggle
                    typeSection
                    
                    // Category Grid
                    categorySection
                    
                    // Optional Fields
                    optionalFieldsSection
                }
                .padding(.vertical, 20)
            }
            
            // Error message
            if let error = viewModel.error {
                Text(error)
                    .font(.system(size: 13, design: .rounded))
                    .foregroundStyle(.red)
                    .padding(.bottom, 8)
            }
            
            // Submit Button
            submitButton
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
        }
    }
    
    // MARK: - Amount Section
    
    private var amountSection: some View {
        VStack(spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("$")
                    .font(.system(size: 28, weight: .medium, design: .rounded))
                    .foregroundStyle(.tertiary)
                
                TextField("0", text: $viewModel.amountString)
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
                    .focused($isAmountFocused)
                    .minimumScaleFactor(0.5)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 20)
            
            Text(viewModel.transactionType == .debit ? "expense" : "income")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .onAppear {
            isAmountFocused = true
        }
    }
    
    // MARK: - Type Section
    
    private var typeSection: some View {
        HStack(spacing: 12) {
            typeButton(type: .debit, emoji: "💸", label: "Expense")
            typeButton(type: .credit, emoji: "💰", label: "Income")
        }
        .padding(.horizontal, 20)
    }
    
    private func typeButton(type: TransactionType, emoji: String, label: String) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.transactionType = type
            }
        } label: {
            VStack(spacing: 6) {
                Text(emoji)
                    .font(.system(size: 28))
                Text(label)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(viewModel.transactionType == type
                          ? Color.accentColor.opacity(0.12)
                          : Color(.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(viewModel.transactionType == type
                            ? Color.accentColor.opacity(0.5)
                            : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: viewModel.transactionType)
    }
    
    // MARK: - Category Section
    
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Category")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(0.5)
                .padding(.horizontal, 20)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(Category.allCases) { category in
                    categoryButton(category)
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private func categoryButton(_ category: Category) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                viewModel.selectedCategory = category
            }
        } label: {
            VStack(spacing: 8) {
                Text(category.emoji)
                    .font(.system(size: 28))
                
                Text(category.displayName)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(viewModel.selectedCategory == category
                          ? category.color.opacity(0.15)
                          : Color(.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(viewModel.selectedCategory == category
                            ? category.color.opacity(0.4)
                            : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: viewModel.selectedCategory)
    }
    
    // MARK: - Optional Fields
    
    private var optionalFieldsSection: some View {
        VStack(spacing: 12) {
            TextField("Merchant (optional)", text: $viewModel.merchant)
                .font(.system(size: 15, design: .rounded))
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            
            TextField("Note (optional)", text: $viewModel.note)
                .font(.system(size: 15, design: .rounded))
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Submit Button
    
    private var submitButton: some View {
        Button {
            isAmountFocused = false
            Task { await viewModel.submit() }
        } label: {
            Group {
                if viewModel.isSubmitting {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(viewModel.submitButtonTitle)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(viewModel.isAmountValid
                          ? Color.accentColor
                          : Color.gray.opacity(0.4))
            )
            .foregroundStyle(.white)
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(!viewModel.isAmountValid || viewModel.isSubmitting)
        .sensoryFeedback(.impact(weight: .medium), trigger: viewModel.isSubmitting)
    }
}

#Preview {
    ExpenseLoggerView()
}
