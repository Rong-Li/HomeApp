//
//  AmountDisplayView.swift
//  HomeApp
//
//  Family Expense Tracker
//

import SwiftUI

struct AmountDisplayView: View {
    let amount: String
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            Text("$")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(.secondary)
            
            Text(formattedDisplay)
                .font(.system(size: 40, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .contentTransition(.numericText())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
    }
    
    private var formattedDisplay: String {
        if amount.isEmpty {
            return "0.00"
        }
        
        if amount.contains(".") {
            let parts = amount.split(separator: ".", omittingEmptySubsequences: false)
            let whole = String(parts[0].isEmpty ? "0" : parts[0])
            let decimal = parts.count > 1 ? String(parts[1]) : ""
            let paddedLength = min(max(decimal.count, 0), 2)
            let paddedDecimal = decimal.padding(toLength: paddedLength, withPad: "0", startingAt: 0)
            return "\(whole).\(paddedDecimal.isEmpty ? "00" : paddedDecimal)"
        } else {
            return "\(amount).00"
        }
    }
}

#Preview {
    VStack {
        AmountDisplayView(amount: "")
        AmountDisplayView(amount: "25")
        AmountDisplayView(amount: "25.5")
        AmountDisplayView(amount: "25.99")
    }
}
