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
    static var description = IntentDescription("Quickly log a new expense with category and amount. Use +/- for income.")
    static var openAppWhenRun: Bool = false
    
    // MARK: - Parameters
    
    @Parameter(
        title: "Category",
        description: "Select expense category",
        requestValueDialog: "Which category?"
    )
    var category: CategoryEntity
    
    @Parameter(
        title: "Amount",
        description: "The amount (use +/- for income)",
        requestValueDialog: "What's the amount?"
    )
    var amount: Double
    
    @Parameter(title: "Merchant", description: "Merchant name (optional)")
    var merchant: String?
    
    @Parameter(
        title: "Note",
        description: "Additional note (optional)",
        requestValueDialog: "Add a note?"
    )
    var note: String?
    
    // MARK: - Parameter Summary
    
    static var parameterSummary: some ParameterSummary {
        Summary("Log \(\.$category) \(\.$amount): \(\.$note)") {
            \.$merchant
        }
    }
    
    // MARK: - Perform
    
    func perform() async throws -> some IntentResult & ShowsSnippetView & ProvidesDialog {
        // Validate inputs
        guard amount != 0 else {
            throw $amount.needsValueError("What amount would you like to log?")
        }
        
        let absAmount = abs(amount)
        
        // Negative amount (via +/- button) = income, positive = expense
        let isCredit = amount < 0
        let transactionType: TransactionType = isCredit ? .credit : .debit
        
        // Prompt for note if not provided
        if note == nil {
            note = try await $note.requestValue("Add a note?")
        }
        
        // Fetch postal code (non-blocking, nil if unavailable)
        let postalCode = await LocationService.shared.fetchPostalCode()
        
        // Create expense
        let expense = ExpenseCreate(
            amount: Decimal(absAmount),
            category: category.toCategory(),
            transactionType: transactionType,
            currency: .cad,
            merchant: merchant?.isEmpty == false ? merchant : nil,
            description: note?.isEmpty == false ? note : nil,
            recurringPayment: nil,
            postalCode: postalCode
        )
        
        do {
            _ = try await APIService.shared.createExpense(expense)
            
            let formattedAmount = NumberFormatter.currency.string(from: NSDecimalNumber(decimal: Decimal(absAmount))) ?? "$\(absAmount)"
            let message = isCredit
                ? "\(category.displayName) +\(formattedAmount)"
                : "\(category.displayName) \(formattedAmount)"
            
            return .result(
                dialog: "Logged \(message)",
                view: ExpenseLoggerConfirmation(message: message)
            )
        } catch {
            throw IntentError.message("Failed to save expense. Please try again.")
        }
    }
}

// MARK: - Category Entity (Expense Only)

enum CategoryEntity: String, AppEnum {
    case groceries = "Groceries"
    case dineOut = "Dine Out"
    case shopping = "Shopping"
    case car = "Car"
    case entertainment = "Entertainment"
    case medical = "Medical"
    case transportation = "Transportation"
    case personalImprovement = "Personal Improvement"
    case housing = "Housing"
    case homeImprovement = "Home Improvement"
    case utilities = "Utilities"
    case gift = "Gift"
    case travel = "Travel"
    case miscellaneous = "Miscellaneous"
    
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Category")
    static var caseDisplayRepresentations: [CategoryEntity: DisplayRepresentation] = [
        .groceries: "🛒  Groceries",
        .dineOut: "🍽️  Dine Out",
        .shopping: "🛍️  Shopping",
        .car: "🚗  Car",
        .entertainment: "🎾  Entertainment",
        .medical: "🏥  Medical",
        .transportation: "🚌  Transportation",
        .personalImprovement: "📚  Personal Improvement",
        .housing: "🏠  Housing",
        .homeImprovement: "🔨  Home Improvement",
        .utilities: "⚡  Utilities",
        .gift: "🎁  Gift",
        .travel: "✈️  Travel",
        .miscellaneous: "📌  Miscellaneous"
    ]
    
    var displayName: String {
        rawValue
    }
    
    func toCategory() -> Category {
        switch self {
        case .groceries: return .groceries
        case .dineOut: return .dineOut
        case .shopping: return .shopping
        case .car: return .car
        case .entertainment: return .entertainment
        case .medical: return .medical
        case .transportation: return .transportation
        case .personalImprovement: return .personalImprovement
        case .housing: return .housing
        case .homeImprovement: return .homeImprovement
        case .utilities: return .utilities
        case .gift: return .gift
        case .travel: return .travel
        case .miscellaneous: return .miscellaneous
        }
    }
}

// MARK: - Number Formatter Extension

private extension NumberFormatter {
    static let currency: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "CAD"
        return formatter
    }()
}

// MARK: - Intent Error

enum IntentError: Error, CustomLocalizedStringResourceConvertible {
    case message(String)
    
    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .message(let message):
            return LocalizedStringResource(stringLiteral: message)
        }
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
