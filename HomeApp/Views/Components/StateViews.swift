//
//  StateViews.swift
//  HomeApp
//
//  Family Expense Tracker
//

import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        ContentUnavailableView(
            title,
            systemImage: icon,
            description: Text(subtitle)
        )
    }
}

struct OfflineStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            
            Text("You're offline")
                .font(.headline)
            
            Text("Connect to the internet to use the app")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

struct ErrorStateView: View {
    let message: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(.red)
            
            Text("Something went wrong")
                .font(.headline)
            
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Try Again", action: retryAction)
                .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

#Preview("Empty") {
    EmptyStateView(
        icon: "tray.fill",
        title: "No transactions",
        subtitle: "Tap + to log your first expense"
    )
}

#Preview("Offline") {
    OfflineStateView()
}

#Preview("Error") {
    ErrorStateView(message: "Unable to load transactions") {}
}
