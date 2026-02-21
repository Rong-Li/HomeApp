//
//  Balance.swift
//  HomeApp
//
//  Family Expense Tracker
//

import Foundation

// MARK: - Balance Record

struct Balance: Identifiable, Codable {
    let id: String
    let cadBalance: Double
    let rmbBalance: Double
    let recordTime: Date
    let note: String?
    let reconciled: Bool
    let cadOffAmount: Double
    let rmbOffAmount: Double
    
    enum CodingKeys: String, CodingKey {
        case id
        case cadBalance = "cad_balance"
        case rmbBalance = "rmb_balance"
        case recordTime = "record_time"
        case note, reconciled
        case cadOffAmount = "cad_off_amount"
        case rmbOffAmount = "rmb_off_amount"
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        formatter.timeZone = TimeZone(identifier: "America/Toronto")
        return formatter.string(from: recordTime)
    }
    
    var formattedCAD: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "CAD"
        return formatter.string(from: NSNumber(value: cadBalance)) ?? "$\(cadBalance)"
    }
    
    var formattedRMB: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "CNY"
        return formatter.string(from: NSNumber(value: rmbBalance)) ?? "¥\(rmbBalance)"
    }
    
    var formattedCADOff: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "CAD"
        let prefix = cadOffAmount >= 0 ? "+" : ""
        return prefix + (formatter.string(from: NSNumber(value: cadOffAmount)) ?? "$\(cadOffAmount)")
    }
}

// MARK: - Balance Input (Create Request)

struct BalanceInput: Encodable {
    let cadBalance: Double
    let rmbBalance: Double
    let recordTime: Date
    let note: String?
    
    enum CodingKeys: String, CodingKey {
        case cadBalance = "cad_balance"
        case rmbBalance = "rmb_balance"
        case recordTime = "record_time"
        case note
    }
}

// MARK: - Balance Response

struct BalanceResponse: Codable {
    let message: String
    let balanceId: String
    let reconciled: Bool
    let cadOffAmount: Double
    let rmbOffAmount: Double
    
    enum CodingKeys: String, CodingKey {
        case message
        case balanceId = "balance_id"
        case reconciled
        case cadOffAmount = "cad_off_amount"
        case rmbOffAmount = "rmb_off_amount"
    }
}
