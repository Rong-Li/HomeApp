//
//  TimeRange.swift
//  HomeApp
//
//  Family Expense Tracker
//

import Foundation

enum TimeRange: String, CaseIterable, Identifiable {
    case oneMonth = "1M"
    case threeMonths = "3M"
    case sixMonths = "6M"
    case oneYear = "1Y"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .oneMonth: return "Last 1 month"
        case .threeMonths: return "Last 3 months"
        case .sixMonths: return "Last 6 months"
        case .oneYear: return "Last 1 year"
        }
    }
    
    var startDate: Date {
        let now = Date()
        switch self {
        case .oneMonth: return Calendar.current.date(byAdding: .month, value: -1, to: now)!
        case .threeMonths: return Calendar.current.date(byAdding: .month, value: -3, to: now)!
        case .sixMonths: return Calendar.current.date(byAdding: .month, value: -6, to: now)!
        case .oneYear: return Calendar.current.date(byAdding: .year, value: -1, to: now)!
        }
    }
}
