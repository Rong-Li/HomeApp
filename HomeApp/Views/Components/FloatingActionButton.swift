//
//  FloatingActionButton.swift
//  HomeApp
//
//  Family Expense Tracker
//

import SwiftUI

struct FloatingActionButton: View {
    let action: () -> Void
    let isDisabled: Bool
    
    init(isDisabled: Bool = false, action: @escaping () -> Void) {
        self.isDisabled = isDisabled
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(Circle().fill(isDisabled ? Color.gray : Color.accentColor))
                .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
        }
        .disabled(isDisabled)
        .sensoryFeedback(.impact(weight: .medium), trigger: isDisabled)
    }
}

#Preview {
    FloatingActionButton(action: {})
}
