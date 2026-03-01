//
//  SuccessView.swift
//  HomeApp
//
//  Family Expense Tracker
//

import SwiftUI

struct SuccessView: View {
    let message: String
    var subtitle: String? = "logged!"
    
    @State private var showCheckmark = false
    @State private var showText = false
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.15))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(.green)
                    .scaleEffect(showCheckmark ? 1 : 0)
                    .opacity(showCheckmark ? 1 : 0)
            }
            
            VStack(spacing: 4) {
                Text(message)
                    .font(.headline)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .opacity(showText ? 1 : 0)
            .offset(y: showText ? 0 : 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                showCheckmark = true
            }
            withAnimation(.easeOut(duration: 0.3).delay(0.2)) {
                showText = true
            }
        }
        .sensoryFeedback(.success, trigger: showCheckmark)
    }
}

#Preview {
    SuccessView(message: "Groceries -$25.00")
}
