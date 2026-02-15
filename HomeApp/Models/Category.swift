//
//  Category.swift
//  HomeApp
//
//  Family Expense Tracker
//

import SwiftUI

enum Category: String, Codable, CaseIterable, Identifiable {
    case groceries = "Groceries"
    case eatOut = "EatOut"
    case transportation = "Transportation"
    case mortgage = "Mortgage"
    case utilities = "Utilities"
    case shopping = "Shopping"
    case gas = "Gas"
    case insurance = "Insurance"
    case salary = "Salary"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .eatOut: return "Eat Out"
        case .salary: return "Salary"
        default: return rawValue
        }
    }
    
    var icon: String {
        switch self {
        case .groceries: return "cart.fill"
        case .eatOut: return "fork.knife"
        case .transportation: return "car.fill"
        case .mortgage: return "house.fill"
        case .utilities: return "bolt.fill"
        case .shopping: return "bag.fill"
        case .gas: return "fuelpump.fill"
        case .insurance: return "shield.fill"
        case .salary: return "dollarsign.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .groceries: return .green
        case .eatOut: return .orange
        case .transportation: return .blue
        case .mortgage: return .purple
        case .utilities: return .yellow
        case .shopping: return .pink
        case .gas: return .red
        case .insurance: return .teal
        case .salary: return .mint
        }
    }
    
    var emoji: String {
        switch self {
        case .groceries: return "🛒"
        case .eatOut: return "🍽️"
        case .transportation: return "🚗"
        case .mortgage: return "🏠"
        case .utilities: return "⚡"
        case .shopping: return "🛍️"
        case .gas: return "⛽"
        case .insurance: return "🛡️"
        case .salary: return "💰"
        }
    }
}
