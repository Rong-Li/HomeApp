//
//  MainTabView.swift
//  HomeApp
//
//  Family Expense Tracker
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            TransactionsView()
                .tabItem {
                    Label("Transactions", systemImage: "list.bullet.rectangle")
                }
                .tag(0)
            
            PlaceholderView(title: "Insights", subtitle: "Coming Soon", icon: "chart.pie")
                .tabItem {
                    Label("Insights", systemImage: "chart.pie")
                }
                .tag(1)
            
            PlaceholderView(title: "Investments", subtitle: "Coming Soon", icon: "chart.line.uptrend.xyaxis")
                .tabItem {
                    Label("Investments", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(2)
            
            PlaceholderView(title: "Settings", subtitle: "Coming Soon", icon: "gearshape")
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(3)
        }
    }
}

// MARK: - Placeholder View for Future Features

struct PlaceholderView: View {
    let title: String
    let subtitle: String
    let icon: String
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 64))
                    .foregroundStyle(.secondary)
                
                Text(subtitle)
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
            .navigationTitle(title)
        }
    }
}

#Preview {
    MainTabView()
}
