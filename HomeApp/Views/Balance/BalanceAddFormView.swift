//
//  BalanceAddFormView.swift
//  HomeApp
//
//  Family Expense Tracker
//

import SwiftUI

struct BalanceAddFormView: View {
    @Environment(\.dismiss) private var dismiss
    let viewModel: BalanceViewModel
    
    @State private var cadAmountText = ""
    @State private var rmbAmountText = ""
    @State private var noteText = ""
    @State private var selectedDate = Date()
    @State private var showValidationError = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Balances") {
                    DatePicker("Record Time", selection: $selectedDate)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.secondary)
                    
                    HStack {
                        Text("CAD $")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.secondary)
                        TextField("0.00", text: $cadAmountText)
                            .font(.system(size: 16, design: .rounded))
                            .keyboardType(.decimalPad)
                    }
                    
                    HStack {
                        Text("RMB ¥")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.secondary)
                        TextField("0.00", text: $rmbAmountText)
                            .font(.system(size: 16, design: .rounded))
                            .keyboardType(.decimalPad)
                    }
                }
                
                Section("Optional") {
                    TextField("Note", text: $noteText)
                        .font(.system(size: 16, design: .rounded))
                }
            }
            .navigationTitle("New Balance")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        if Double(cadAmountText) != nil && Double(rmbAmountText) != nil {
                            submitBalance()
                        } else {
                            showValidationError = true
                        }
                    }
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .disabled(viewModel.isSaving)
                }
            }
            .alert("Invalid Form", isPresented: $showValidationError) {
                Button("OK") {}
            } message: {
                Text("Please enter valid CAD and RMB balance amounts.")
            }
        }
    }
    
    private func submitBalance() {
        guard let cad = Double(cadAmountText), let rmb = Double(rmbAmountText) else { return }
        let input = BalanceInput(
            cadBalance: cad,
            rmbBalance: rmb,
            recordTime: selectedDate,
            note: noteText.isEmpty ? nil : noteText
        )
        Task {
            if await viewModel.createBalance(input) {
                dismiss()
            }
        }
    }
}
