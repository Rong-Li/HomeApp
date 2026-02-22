//
//  Category.swift
//  HomeApp
//
//  Family Expense Tracker
//

import SwiftUI

enum Category: String, Codable, CaseIterable, Identifiable {
    // Expense categories
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
    
    // Earning categories
    case salary = "Salary"
    case taxReturn = "Tax Return"
    case cashBack = "Cash Back"
    
    var id: String { rawValue }
    
    // MARK: - Category Classification
    
    var isExpense: Bool {
        switch self {
        case .groceries, .dineOut, .shopping, .car, .entertainment,
             .medical, .transportation, .personalImprovement,
             .housing, .homeImprovement, .utilities, .gift,
             .travel, .miscellaneous:
            return true
        case .salary, .taxReturn, .cashBack:
            return false
        }
    }
    
    var isEarning: Bool { !isExpense }
    
    static var expenseCases: [Category] {
        allCases.filter { $0.isExpense }
    }
    
    static var earningCases: [Category] {
        allCases.filter { $0.isEarning }
    }
    
    // MARK: - Display
    
    var displayName: String {
        rawValue
    }
    
    var icon: String {
        switch self {
        // Expense
        case .groceries: return "cart.fill"
        case .dineOut: return "fork.knife"
        case .shopping: return "bag.fill"
        case .car: return "car.fill"
        case .entertainment: return "figure.tennis"
        case .medical: return "cross.case.fill"
        case .transportation: return "bus.fill"
        case .personalImprovement: return "book.fill"
        case .housing: return "house.fill"
        case .homeImprovement: return "hammer.fill"
        case .utilities: return "bolt.fill"
        case .gift: return "gift.fill"
        case .travel: return "airplane"
        case .miscellaneous: return "ellipsis.circle.fill"
        // Earning
        case .salary: return "dollarsign.circle.fill"
        case .taxReturn: return "doc.text.fill"
        case .cashBack: return "creditcard.fill"
        }
    }
    
    var color: Color {
        switch self {
        // Expense
        case .groceries: return .green
        case .dineOut: return .orange
        case .shopping: return .pink
        case .car: return .red
        case .entertainment: return Color(hue: 0.18, saturation: 0.8, brightness: 0.9)
        case .medical: return .blue
        case .transportation: return .cyan
        case .personalImprovement: return .indigo
        case .housing: return .brown
        case .homeImprovement: return .yellow
        case .utilities: return .teal
        case .gift: return Color(hue: 0.85, saturation: 0.6, brightness: 0.9)
        case .travel: return Color(hue: 0.55, saturation: 0.7, brightness: 0.8)
        case .miscellaneous: return .gray
        // Earning
        case .salary: return .mint
        case .taxReturn: return Color(hue: 0.3, saturation: 0.5, brightness: 0.7)
        case .cashBack: return Color(hue: 0.45, saturation: 0.6, brightness: 0.75)
        }
    }
    
    var emoji: String {
        switch self {
        // Expense
        case .groceries: return "🛒"
        case .dineOut: return "🍽️"
        case .shopping: return "🛍️"
        case .car: return "🚗"
        case .entertainment: return "🎾"
        case .medical: return "🏥"
        case .transportation: return "🚌"
        case .personalImprovement: return "📚"
        case .housing: return "🏠"
        case .homeImprovement: return "🔨"
        case .utilities: return "⚡"
        case .gift: return "🎁"
        case .travel: return "✈️"
        case .miscellaneous: return "📌"
        // Earning
        case .salary: return "💰"
        case .taxReturn: return "🧾"
        case .cashBack: return "💳"
        }
    }
}
