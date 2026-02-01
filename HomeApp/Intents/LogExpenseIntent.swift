//
//  LogExpenseIntent.swift
//  HomeApp
//
//  Family Expense Tracker - Action Button Integration
//

import AppIntents
import SwiftUI

struct LogExpenseIntent: AppIntent {
    static var title: LocalizedStringResource = "Log Expense"
    static var description = IntentDescription("Quickly log a new expense")
    static var openAppWhenRun: Bool = false
    
    @MainActor
    func perform() async throws -> some IntentResult & ShowsSnippetView {
        return .result(view: ExpenseLoggerSnippetView())
    }
}

// MARK: - App Shortcuts

struct HomeAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: LogExpenseIntent(),
            phrases: [
                "Log expense in \(.applicationName)",
                "Add expense to \(.applicationName)",
                "Record expense with \(.applicationName)"
            ],
            shortTitle: "Log Expense",
            systemImageName: "plus.circle.fill"
        )
    }
}

// MARK: - Snippet View for Action Button

struct ExpenseLoggerSnippetView: View {
    @State private var viewModel = ExpenseLoggerViewModel()
    
    var body: some View {
        VStack(spacing: 8) {
            if viewModel.showSuccess {
                compactSuccessView
            } else {
                compactFormView
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .animation(.easeInOut(duration: 0.25), value: viewModel.showSuccess)
    }
    
    private var compactSuccessView: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.15))
                    .frame(width: 60, height: 60)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(.green)
            }
            
            VStack(spacing: 2) {
                Text(viewModel.successMessage)
                    .font(.subheadline.bold())
                Text("logged!")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(height: 150)
    }
    
    private var compactFormView: some View {
        VStack(spacing: 8) {
            // Header
            Text("Log Expense")
                .font(.headline)
            
            // Amount (compact)
            Text(viewModel.formattedAmount)
                .font(.system(size: 28, weight: .semibold, design: .rounded))
            
            // Type toggle (compact)
            Picker("Type", selection: $viewModel.transactionType) {
                Text("Debit").tag(TransactionType.debit)
                Text("Credit").tag(TransactionType.credit)
            }
            .pickerStyle(.segmented)
            .frame(width: 140)
            
            // Category picker (compact)
            Picker("Category", selection: $viewModel.selectedCategory) {
                ForEach(Category.allCases) { category in
                    HStack {
                        Image(systemName: category.icon)
                            .foregroundStyle(category.color)
                        Text(category.displayName)
                    }
                    .tag(category)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 80)
            
            // Optional fields (compact)
            HStack(spacing: 4) {
                TextField("Merchant", text: $viewModel.merchant)
                    .textFieldStyle(.roundedBorder)
                    .font(.caption)
                TextField("Note", text: $viewModel.note)
                    .textFieldStyle(.roundedBorder)
                    .font(.caption)
            }
            
            // Keypad and submit (compact)
            HStack(alignment: .bottom, spacing: 6) {
                // Compact keypad
                VStack(spacing: 3) {
                    ForEach(0..<4, id: \.self) { row in
                        HStack(spacing: 3) {
                            ForEach(0..<3, id: \.self) { col in
                                compactKeyButton(row: row, col: col)
                            }
                        }
                    }
                }
                
                // Submit button
                Button {
                    Task { await viewModel.submit() }
                } label: {
                    VStack(spacing: 2) {
                        if viewModel.isSubmitting {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 20))
                            Text("Log")
                                .font(.caption2.bold())
                        }
                    }
                    .frame(width: 44, height: 70)
                    .background(viewModel.isAmountValid ? Color.accentColor : Color.gray)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .disabled(!viewModel.isAmountValid || viewModel.isSubmitting)
            }
            
            if let error = viewModel.error {
                Text(error)
                    .font(.caption2)
                    .foregroundStyle(.red)
            }
        }
    }
    
    private func compactKeyButton(row: Int, col: Int) -> some View {
        let keys = [
            ["1", "2", "3"],
            ["4", "5", "6"],
            ["7", "8", "9"],
            [".", "0", "⌫"]
        ]
        let key = keys[row][col]
        
        return Button {
            if key == "⌫" {
                viewModel.deleteLastDigit()
            } else {
                viewModel.appendDigit(key)
            }
        } label: {
            Text(key)
                .font(.system(size: 14, weight: .medium))
                .frame(width: 38, height: 30)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ExpenseLoggerSnippetView()
}
