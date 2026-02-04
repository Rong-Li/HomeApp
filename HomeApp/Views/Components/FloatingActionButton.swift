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
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 60, height: 60)
                .background(
                    Circle()
                        .fill(
                            isDisabled
                                ? AnyShapeStyle(Color.gray)
                                : AnyShapeStyle(
                                    LinearGradient(
                                        colors: [Color.accentColor, Color.accentColor.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                )
                .shadow(color: isDisabled ? .clear : Color.accentColor.opacity(0.4), radius: 8, y: 4)
                .shadow(color: .black.opacity(0.15), radius: 3, y: 1)
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(isDisabled)
        .sensoryFeedback(.impact(weight: .medium), trigger: isDisabled)
    }
}

// Custom button style for press animation
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

#Preview {
    FloatingActionButton(action: {})
}
