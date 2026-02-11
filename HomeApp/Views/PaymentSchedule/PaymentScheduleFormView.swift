//
//  PaymentScheduleFormView.swift
//  HomeApp
//
//  Family Expense Tracker
//

import SwiftUI

struct PaymentScheduleFormView: View {
    @Environment(\.dismiss) private var dismiss
    
    let viewModel: PaymentScheduleViewModel
    let existingSchedule: PaymentSchedule?
    
    // Form fields
    @State private var name: String = ""
    @State private var amountText: String = ""
    @State private var currency: Currency = .cad
    @State private var transactionType: TransactionType = .debit
    @State private var category: Category = .utilities
    @State private var frequency: ScheduleFrequency = .monthly
    @State private var monthlyDates: Set<Int> = [1]
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()
    @State private var hasEndDate: Bool = false
    @State private var merchant: String = ""
    @State private var descriptionText: String = ""
    
    @State private var showValidationError: Bool = false
    
    private var isEditing: Bool { existingSchedule != nil }
    
    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        Decimal(string: amountText) != nil &&
        (Decimal(string: amountText) ?? 0) > 0 &&
        (frequency != .monthly || !monthlyDates.isEmpty)
    }
    
    init(viewModel: PaymentScheduleViewModel, schedule: PaymentSchedule? = nil) {
        self.viewModel = viewModel
        self.existingSchedule = schedule
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Basic info
                Section("Details") {
                    TextField("Name", text: $name)
                        .font(.system(size: 16, design: .rounded))
                    
                    HStack {
                        Text(currency.symbol)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.secondary)
                        TextField("Amount", text: $amountText)
                            .font(.system(size: 16, design: .rounded))
                            .keyboardType(.decimalPad)
                    }
                    
                    Picker("Currency", selection: $currency) {
                        ForEach(Currency.allCases, id: \.self) { c in
                            Text("\(c.flag) \(c.rawValue)").tag(c)
                        }
                    }
                    
                    Picker("Type", selection: $transactionType) {
                        Text("Debit").tag(TransactionType.debit)
                        Text("Credit").tag(TransactionType.credit)
                    }
                }
                
                // Category
                Section("Category") {
                    Picker("Category", selection: $category) {
                        ForEach(Category.allCases) { cat in
                            HStack {
                                Text(cat.emoji)
                                Text(cat.displayName)
                            }
                            .tag(cat)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }
                
                // Frequency
                Section("Frequency") {
                    Picker("Frequency", selection: $frequency) {
                        ForEach(ScheduleFrequency.allCases) { freq in
                            Text(freq.displayName).tag(freq)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    if frequency == .monthly {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Payment days (1–28)")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundStyle(.secondary)
                            
                            monthlyDaysPicker
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                // Dates
                Section("Schedule Period") {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                        .font(.system(size: 16, design: .rounded))
                    
                    Toggle("Set End Date", isOn: $hasEndDate)
                        .font(.system(size: 16, design: .rounded))
                    
                    if hasEndDate {
                        DatePicker("End Date", selection: $endDate, in: startDate..., displayedComponents: .date)
                            .font(.system(size: 16, design: .rounded))
                    }
                }
                
                // Optional info
                Section("Optional") {
                    TextField("Merchant", text: $merchant)
                        .font(.system(size: 16, design: .rounded))
                    TextField("Description", text: $descriptionText)
                        .font(.system(size: 16, design: .rounded))
                }
            }
            .navigationTitle(isEditing ? "Edit Schedule" : "New Schedule")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Save" : "Add") {
                        if isFormValid {
                            saveSchedule()
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
                Text("Please fill in the name and a valid amount. Monthly schedules need at least one payment day.")
            }
            .onAppear { populateForm() }
        }
    }
    
    // MARK: - Monthly Days Picker
    
    private var monthlyDaysPicker: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
        return LazyVGrid(columns: columns, spacing: 4) {
            ForEach(1...28, id: \.self) { day in
                Button {
                    if monthlyDates.contains(day) {
                        monthlyDates.remove(day)
                    } else {
                        monthlyDates.insert(day)
                    }
                } label: {
                    Text("\(day)")
                        .font(.system(size: 13, weight: monthlyDates.contains(day) ? .bold : .regular, design: .rounded))
                        .frame(width: 34, height: 34)
                        .background(
                            Circle()
                                .fill(monthlyDates.contains(day)
                                      ? Color.accentColor
                                      : Color(.tertiarySystemFill))
                        )
                        .foregroundStyle(monthlyDates.contains(day) ? .white : .primary)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    // MARK: - Actions
    
    private func populateForm() {
        guard let s = existingSchedule else { return }
        name = s.name
        amountText = "\(s.amount)"
        currency = s.currency
        transactionType = s.transactionType
        category = s.category
        frequency = s.frequency
        monthlyDates = Set(s.monthlyDates ?? [])
        startDate = s.startDate
        if let end = s.endDate {
            hasEndDate = true
            endDate = end
        }
        merchant = s.merchant ?? ""
        descriptionText = s.description ?? ""
    }
    
    private func saveSchedule() {
        guard let amount = Decimal(string: amountText) else { return }
        
        let create = PaymentScheduleCreate(
            name: name.trimmingCharacters(in: .whitespaces),
            amount: amount,
            currency: currency,
            transactionType: transactionType,
            category: category,
            frequency: frequency,
            monthlyDates: frequency == .monthly ? monthlyDates.sorted() : nil,
            startDate: startDate,
            endDate: hasEndDate ? endDate : nil,
            merchant: merchant.isEmpty ? nil : merchant,
            description: descriptionText.isEmpty ? nil : descriptionText
        )
        
        Task {
            let success: Bool
            if let existing = existingSchedule {
                success = await viewModel.updateSchedule(id: existing.id, create)
            } else {
                success = await viewModel.createSchedule(create)
            }
            if success {
                dismiss()
            }
        }
    }
}
