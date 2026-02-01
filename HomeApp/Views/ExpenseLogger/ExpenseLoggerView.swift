//
//  ExpenseLoggerView.swift
//  HomeApp
//
//  Family Expense Tracker
//

import SwiftUI

struct ExpenseLoggerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = ExpenseLoggerViewModel()
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
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .interactiveDismissDisabled(viewModel.isSubmitting)
    }
    
    private var formContent: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Amount
                AmountDisplayView(amount: viewModel.amountString)
                
                // Type Toggle
                TransactionTypeToggle(selection: $viewModel.transactionType)
                
                // Category Picker
                CategoryPickerView(selectedCategory: $viewModel.selectedCategory)
                
                // Optional Fields
                VStack(spacing: 8) {
                    TextField("Merchant name (optional)", text: $viewModel.merchant)
                        .textFieldStyle(.roundedBorder)
                    
                    TextField("Note (optional)", text: $viewModel.note)
                        .textFieldStyle(.roundedBorder)
                }
                .padding(.horizontal)
                
                // Error message
                if let error = viewModel.error {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
                
                // Numeric Keypad
                NumericKeypadView(
                    onDigit: viewModel.appendDigit,
                    onDelete: viewModel.deleteLastDigit
                )
                .padding(.horizontal)
                
                // Submit Button
                Button {
                    Task { await viewModel.submit() }
                } label: {
                    Group {
                        if viewModel.isSubmitting {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text(viewModel.submitButtonTitle)
                                .font(.headline)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(viewModel.isAmountValid ? Color.accentColor : Color.gray)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(!viewModel.isAmountValid || viewModel.isSubmitting)
                .padding(.horizontal)
                .sensoryFeedback(.impact(weight: .medium), trigger: viewModel.isSubmitting)
            }
            .padding(.vertical)
        }
    }
}

#Preview {
    ExpenseLoggerView()
}
