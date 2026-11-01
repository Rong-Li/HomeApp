//
//  Report.swift
//  HomeApp
//
//  Insights API response models
//

import Foundation

// MARK: - Spending Trend

struct TrendMonthEntry: Codable {
    let month: String
    let netExpense: Double
    
    enum CodingKeys: String, CodingKey {
        case month
        case netExpense = "net_expense"
    }
}

struct CurrentMonthSummary: Codable {
    let month: String
    let netExpense: Double
    let daysRemaining: Int
    
    enum CodingKeys: String, CodingKey {
        case month
        case netExpense = "net_expense"
        case daysRemaining = "days_remaining"
    }
}

struct TrendResponse: Codable {
    let monthsRequested: Int
    let categoryFilter: String?
    let currentMonth: CurrentMonthSummary
    let previousMonthEarning: Double
    let trend: [TrendMonthEntry]
    
    enum CodingKeys: String, CodingKey {
        case monthsRequested = "months_requested"
        case categoryFilter = "category_filter"
        case currentMonth = "current_month"
        case previousMonthEarning = "previous_month_earning"
        case trend
    }
}

// MARK: - Category Breakdown

struct CategorySnapshotMonth: Codable {
    let month: String
    let netExpense: Double
    let netByCategory: [String: Double]
    let countByCategory: [String: Int]
    
    enum CodingKeys: String, CodingKey {
        case month
        case netExpense = "net_expense"
        case netByCategory = "net_by_category"
        case countByCategory = "count_by_category"
    }
}

struct CategorySnapshotYear: Codable {
    let year: String
    let netExpense: Double
    let netByCategory: [String: Double]
    let countByCategory: [String: Int]
    
    enum CodingKeys: String, CodingKey {
        case year
        case netExpense = "net_expense"
        case netByCategory = "net_by_category"
        case countByCategory = "count_by_category"
    }
}

struct CategoryBreakdownResponse: Codable {
    let lastMonth: CategorySnapshotMonth?
    let currentYear: CategorySnapshotYear?
    let lastYear: CategorySnapshotYear?
    let currentMonth: CategorySnapshotMonth?
    let currentYearMonths: [CategorySnapshotMonth]?
    
    enum CodingKeys: String, CodingKey {
        case lastMonth = "last_month"
        case currentYear = "current_year"
        case lastYear = "last_year"
        case currentMonth = "current_month"
        case currentYearMonths = "current_year_months"
    }
}

extension CategoryBreakdownResponse {
    /// Compatibility with servers that only return last-month and yearly reports.
    /// Use the same UTC month boundaries and debit-minus-credit category rules.
    func withMonthlySnapshots(from transactions: [Transaction], through date: Date) -> CategoryBreakdownResponse {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let year = calendar.component(.year, from: date)
        let currentMonthNumber = calendar.component(.month, from: date)
        let expenseTransactions = transactions.filter {
            $0.category.isExpense && calendar.component(.year, from: $0.createdAt) == year
        }
        let byMonth = Dictionary(grouping: expenseTransactions) { calendar.component(.month, from: $0.createdAt) }
        let snapshots = (1...currentMonthNumber).map { month in
            var amounts: [String: Decimal] = [:]
            var counts: [String: Int] = [:]
            for transaction in byMonth[month] ?? [] {
                let category = transaction.category.rawValue
                amounts[category, default: 0] += transaction.isCredit ? -transaction.amount : transaction.amount
                counts[category, default: 0] += 1
            }
            return CategorySnapshotMonth(
                month: String(format: "%04d-%02d", year, month),
                netExpense: NSDecimalNumber(decimal: amounts.values.reduce(0, +)).doubleValue,
                netByCategory: amounts.filter { $0.value != 0 }.mapValues { NSDecimalNumber(decimal: $0).doubleValue },
                countByCategory: counts
            )
        }
        return CategoryBreakdownResponse(
            lastMonth: lastMonth, currentYear: currentYear, lastYear: lastYear,
            currentMonth: snapshots.last, currentYearMonths: snapshots
        )
    }
}
