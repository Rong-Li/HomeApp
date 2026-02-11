//
//  PaymentSchedule.swift
//  HomeApp
//
//  Family Expense Tracker
//

import Foundation

// MARK: - Schedule Frequency

enum ScheduleFrequency: String, Codable, CaseIterable, Identifiable {
    case weekly = "Weekly"
    case biweekly = "Biweekly"
    case monthly = "Monthly"
    
    var id: String { rawValue }
    
    var displayName: String { rawValue }
    
    var icon: String {
        switch self {
        case .weekly: return "calendar.badge.clock"
        case .biweekly: return "calendar"
        case .monthly: return "calendar.circle"
        }
    }
}

// MARK: - Payment Schedule

struct PaymentSchedule: Identifiable, Codable, Equatable {
    let id: String
    var name: String
    var amount: Decimal
    var currency: Currency
    var transactionType: TransactionType
    var category: Category
    var frequency: ScheduleFrequency
    var monthlyDates: [Int]?
    var startDate: Date
    var endDate: Date?
    var merchant: String?
    var description: String?
    var createdAt: Date
    var updatedAt: Date
    
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency.rawValue
        let prefix = transactionType == .credit ? "+" : "-"
        return prefix + (formatter.string(from: amount as NSDecimalNumber) ?? "\(currency.symbol)0.00")
    }
    
    var frequencyLabel: String {
        switch frequency {
        case .monthly:
            if let dates = monthlyDates, !dates.isEmpty {
                let dayStrings = dates.sorted().map { "\($0)" }
                return "Monthly on day \(dayStrings.joined(separator: ", "))"
            }
            return "Monthly"
        case .biweekly:
            return "Every 2 weeks"
        case .weekly:
            return "Weekly"
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, amount, currency, category, frequency, merchant, description
        case transactionType = "transaction_type"
        case monthlyDates = "monthly_dates"
        case startDate = "start_date"
        case endDate = "end_date"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Payment Schedule Create / Update

struct PaymentScheduleCreate: Encodable {
    let name: String
    let amount: Decimal
    let currency: Currency
    let transactionType: TransactionType
    let category: Category
    let frequency: ScheduleFrequency
    let monthlyDates: [Int]?
    let startDate: Date
    let endDate: Date?
    let merchant: String?
    let description: String?
    
    enum CodingKeys: String, CodingKey {
        case name, amount, currency, category, frequency, merchant, description
        case transactionType = "transaction_type"
        case monthlyDates = "monthly_dates"
        case startDate = "start_date"
        case endDate = "end_date"
    }
}
