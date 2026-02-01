//
//  TransactionTypeToggle.swift
//  HomeApp
//
//  Family Expense Tracker
//

import SwiftUI

struct TransactionTypeToggle: View {
    @Binding var selection: TransactionType
    
    var body: some View {
        Picker("Type", selection: $selection) {
            Text("Debit").tag(TransactionType.debit)
            Text("Credit").tag(TransactionType.credit)
        }
        .pickerStyle(.segmented)
        .frame(width: 180)
        .sensoryFeedback(.selection, trigger: selection)
    }
}

#Preview {
    TransactionTypeToggle(selection: .constant(.debit))
}
