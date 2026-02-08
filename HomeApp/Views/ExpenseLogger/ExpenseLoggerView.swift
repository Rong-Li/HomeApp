//
//  ExpenseLoggerView.swift
//  HomeApp
//
//  Family Expense Tracker - Apple-like Minimalistic Design
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
                    .foregroundStyle(.secondary)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isAmountFocused = false
                        Task { await viewModel.submit() }
                    } label: {
                        if viewModel.isSubmitting {
                            ProgressView()
                        } else {
                            Text("Save")
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(!viewModel.isAmountValid || viewModel.isSubmitting)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .interactiveDismissDisabled(viewModel.isSubmitting)
    }
    
    private var formContent: some View {
        VStack(spacing: 0) {
            // Amount + Type on same row
            HStack(spacing: 16) {
                // Amount input
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(viewModel.selectedCurrency.symbol)
                        .font(.system(size: 24, weight: .light, design: .rounded))
                        .foregroundStyle(.secondary)
                    
                    TextField("0", text: $viewModel.amountString)
                        .font(.system(size: 36, weight: .semibold, design: .rounded))
                        .keyboardType(.decimalPad)
                        .focused($isAmountFocused)
                        .minimumScaleFactor(0.5)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Currency toggle
                Button {
                    viewModel.selectedCurrency = viewModel.selectedCurrency == .cad ? .rmb : .cad
                } label: {
                    Text(viewModel.selectedCurrency.flag)
                        .font(.title2)
                }
                .buttonStyle(.bordered)
                .sensoryFeedback(.selection, trigger: viewModel.selectedCurrency)
                
                // Type toggle (compact)
                Picker("Type", selection: $viewModel.transactionType) {
                    Image(systemName: "arrow.up.right").tag(TransactionType.debit)
                    Image(systemName: "arrow.down.left").tag(TransactionType.credit)
                }
                .pickerStyle(.segmented)
                .frame(width: 100)
                .sensoryFeedback(.selection, trigger: viewModel.transactionType)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .background(Color(.secondarySystemBackground))
            .onAppear { isAmountFocused = true }
            
            // Form fields
            List {
                // Category & Date row
                Section {
                    categoryRow
                    dateRow
                }
                
                // Details section
                Section {
                    TextField("Merchant", text: $viewModel.merchant)
                    TextField("Note", text: $viewModel.note)
                } header: {
                    Text("Details (Optional)")
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            
            // Error
            if let error = viewModel.error {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .padding(.bottom, 8)
            }
        }
    }
    
    // MARK: - Category Row
    
    private var categoryRow: some View {
        Picker(selection: $viewModel.selectedCategory) {
            ForEach(Category.allCases) { category in
                HStack(spacing: 8) {
                    Text(category.emoji)
                    Text(category.displayName)
                }
                .tag(category)
            }
        } label: {
            HStack {
                Text("Category")
                Spacer()
            }
        }
        .pickerStyle(.navigationLink)
        .sensoryFeedback(.selection, trigger: viewModel.selectedCategory)
    }
    
    // MARK: - Date Row
    
    private var dateRow: some View {
        DatePicker(
            "Date",
            selection: $viewModel.selectedDate,
            displayedComponents: [.date, .hourAndMinute]
        )
        .sensoryFeedback(.selection, trigger: viewModel.selectedDate)
    }
}

#Preview {
    ExpenseLoggerView()
}
