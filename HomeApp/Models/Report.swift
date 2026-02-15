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
    
    enum CodingKeys: String, CodingKey {
        case lastMonth = "last_month"
        case currentYear = "current_year"
        case lastYear = "last_year"
    }
}
