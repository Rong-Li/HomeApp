//
//  NumericKeypadView.swift
//  HomeApp
//
//  Family Expense Tracker
//

import SwiftUI

struct NumericKeypadView: View {
    let onDigit: (String) -> Void
    let onDelete: () -> Void
    
    private let keys: [[KeypadKey]] = [
        [.digit("1"), .digit("2"), .digit("3")],
        [.digit("4"), .digit("5"), .digit("6")],
        [.digit("7"), .digit("8"), .digit("9")],
        [.digit("."), .digit("0"), .delete]
    ]
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(keys.indices, id: \.self) { row in
                HStack(spacing: 8) {
                    ForEach(keys[row].indices, id: \.self) { col in
                        keyButton(keys[row][col])
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func keyButton(_ key: KeypadKey) -> some View {
        Button {
            switch key {
            case .digit(let value):
                onDigit(value)
            case .delete:
                onDelete()
            }
        } label: {
            Group {
                switch key {
                case .digit(let value):
                    Text(value)
                        .font(.system(size: 24, weight: .medium, design: .rounded))
                case .delete:
                    Image(systemName: "delete.left")
                        .font(.system(size: 20, weight: .medium))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: .black.opacity(0.04), radius: 2, y: 1)
        }
        .buttonStyle(ScaleButtonStyle())
        .sensoryFeedback(.impact(weight: .light), trigger: key.id)
    }
}

enum KeypadKey: Identifiable {
    case digit(String)
    case delete
    
    var id: String {
        switch self {
        case .digit(let value): return value
        case .delete: return "delete"
        }
    }
}

#Preview {
    NumericKeypadView(onDigit: { _ in }, onDelete: {})
        .padding()
}
