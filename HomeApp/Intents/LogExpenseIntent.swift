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
    static var description = IntentDescription("Quickly log a new expense with category, amount, and type")
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
        description: "The expense amount",
        requestValueDialog: "What's the amount?"
    )
    var amount: Double
    
    @Parameter(
        title: "Type",
        description: "Transaction type",
        default: .debit
    )
    var transactionType: TransactionTypeEntity
    
    @Parameter(title: "Merchant", description: "Merchant name (optional)")
    var merchant: String?
    
    @Parameter(title: "Note", description: "Additional note (optional)")
    var note: String?
    
    // MARK: - Parameter Summary
    
    static var parameterSummary: some ParameterSummary {
        Summary("Log \(\.$category) \(\.$transactionType) of \(\.$amount)") {
            \.$merchant
            \.$note
        }
    }
    
    // MARK: - Perform
    
    func perform() async throws -> some IntentResult & ShowsSnippetView & ProvidesDialog {
        // Validate inputs - this ensures the system prompts for missing values
        guard amount > 0 else {
            throw $amount.needsValueError("What amount would you like to log?")
        }
        
        // Create expense
        let expense = ExpenseCreate(
            amount: Decimal(amount),
            category: category.toCategory(),
            transactionType: transactionType.toTransactionType(),
            merchant: merchant?.isEmpty == false ? merchant : nil,
            description: note?.isEmpty == false ? note : nil,
            recurringPayment: nil
        )
        
        do {
            _ = try await APIService.shared.createExpense(expense)
            
            let formattedAmount = NumberFormatter.currency.string(from: NSDecimalNumber(decimal: Decimal(amount))) ?? "$\(amount)"
            let sign = transactionType.toTransactionType() == .debit ? "-" : "+"
            let message = "\(category.displayName) \(sign)\(formattedAmount)"
            
            return .result(
                dialog: "Logged \(message)",
                view: ExpenseLoggerSnippetView(message: message)
            )
        } catch {
            throw IntentError.message("Failed to save expense. Please try again.")
        }
    }
}

// MARK: - Category Entity

enum CategoryEntity: String, AppEnum {
    case groceries = "Groceries"
    case eatOut = "EatOut"
    case transportation = "Transportation"
    case mortgage = "Mortgage"
    case utilities = "Utilities"
    case shopping = "Shopping"
    case gas = "Gas"
    case insurance = "Insurance"
    
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Category")
    static var caseDisplayRepresentations: [CategoryEntity: DisplayRepresentation] = [
        .groceries: DisplayRepresentation(title: "Groceries", image: DisplayRepresentation.Image(systemName: "cart.fill")),
        .eatOut: DisplayRepresentation(title: "Eat Out", image: DisplayRepresentation.Image(systemName: "fork.knife")),
        .transportation: DisplayRepresentation(title: "Transportation", image: DisplayRepresentation.Image(systemName: "car.fill")),
        .mortgage: DisplayRepresentation(title: "Mortgage", image: DisplayRepresentation.Image(systemName: "house.fill")),
        .utilities: DisplayRepresentation(title: "Utilities", image: DisplayRepresentation.Image(systemName: "bolt.fill")),
        .shopping: DisplayRepresentation(title: "Shopping", image: DisplayRepresentation.Image(systemName: "bag.fill")),
        .gas: DisplayRepresentation(title: "Gas", image: DisplayRepresentation.Image(systemName: "fuelpump.fill")),
        .insurance: DisplayRepresentation(title: "Insurance", image: DisplayRepresentation.Image(systemName: "shield.fill"))
    ]
    
    var displayName: String {
        switch self {
        case .eatOut: return "Eat Out"
        default: return rawValue
        }
    }
    
    func toCategory() -> Category {
        switch self {
        case .groceries: return .groceries
        case .eatOut: return .eatOut
        case .transportation: return .transportation
        case .mortgage: return .mortgage
        case .utilities: return .utilities
        case .shopping: return .shopping
        case .gas: return .gas
        case .insurance: return .insurance
        }
    }
}

// MARK: - Transaction Type Entity

enum TransactionTypeEntity: String, AppEnum {
    case debit = "Expense"
    case credit = "Income"
    
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Type")
    static var caseDisplayRepresentations: [TransactionTypeEntity: DisplayRepresentation] = [
        .debit: DisplayRepresentation(title: "Expense", image: DisplayRepresentation.Image(systemName: "minus.circle.fill")),
        .credit: DisplayRepresentation(title: "Income", image: DisplayRepresentation.Image(systemName: "plus.circle.fill"))
    ]
    
    func toTransactionType() -> TransactionType {
        switch self {
        case .debit: return .debit
        case .credit: return .credit
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
