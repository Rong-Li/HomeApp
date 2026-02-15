//
//  InsightsView.swift
//  HomeApp
//
//  Insights tab with spending trend bar chart and category donut chart
//

import SwiftUI
import Charts

struct InsightsView: View {
    @StateObject private var viewModel = InsightsViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    spendingSummarySection
                    categoryBreakdownSection
                }
                .padding()
            }
            .navigationTitle("Insights")
            .task {
                await viewModel.loadAllData()
            }
        }
    }
    
    // MARK: - Spending Summary Section
    
    private var spendingSummarySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            if let current = viewModel.trendResponse?.currentMonth {
                Text(monthDisplayName(current.month) + " Spending")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                Text(formatCurrency(current.netExpense))
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                
                HStack(spacing: 16) {
                    if let earning = viewModel.trendResponse?.previousMonthEarning, earning > 0 {
                        Label("Last month earnings: \(formatCurrency(earning))", systemImage: "arrow.up.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.green)
                    }
                    
                    Label("\(current.daysRemaining) days left", systemImage: "calendar")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Bar Chart
            if let trend = viewModel.trendResponse {
                spendingBarChart(trend: trend)
            } else if viewModel.isTrendLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 200)
            } else if let error = viewModel.trendError {
                ContentUnavailableView(error, systemImage: "exclamationmark.triangle")
            }
            
            // Selectors
            HStack {
                // Time range picker
                HStack(spacing: 4) {
                    ForEach([6, 12, 18, 24], id: \.self) { months in
                        Button("\(months)M") {
                            Task { await viewModel.onMonthsChanged(months) }
                        }
                        .font(.caption.weight(viewModel.selectedMonths == months ? .bold : .regular))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            viewModel.selectedMonths == months
                            ? Color.green.opacity(0.2)
                            : Color(.systemGray6)
                        )
                        .foregroundStyle(viewModel.selectedMonths == months ? .green : .secondary)
                        .clipShape(Capsule())
                    }
                }
                
                Spacer()
                
                // Category filter
                Menu {
                    Button("All Categories") {
                        Task { await viewModel.onCategoryChanged(nil) }
                    }
                    ForEach(viewModel.availableCategories, id: \.self) { cat in
                        Button(cat) {
                            Task { await viewModel.onCategoryChanged(cat) }
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(viewModel.selectedCategory ?? "All")
                            .font(.caption)
                        Image(systemName: "chevron.down")
                            .font(.caption2)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color(.systemGray6))
                    .clipShape(Capsule())
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }
    
    private func spendingBarChart(trend: TrendResponse) -> some View {
        let allEntries = trend.trend + [
            TrendMonthEntry(month: trend.currentMonth.month, netExpense: trend.currentMonth.netExpense)
        ]
        
        return Chart(allEntries, id: \.month) { entry in
            BarMark(
                x: .value("Month", shortMonth(entry.month)),
                y: .value("Spending", entry.netExpense)
            )
            .foregroundStyle(
                entry.month == trend.currentMonth.month
                ? Color.green.opacity(0.4)
                : Color.green
            )
            .cornerRadius(4)
        }
        .frame(height: 200)
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisValueLabel {
                    if let v = value.as(Double.self) {
                        Text(compactCurrency(v))
                            .font(.caption2)
                    }
                }
            }
        }
        .chartXAxis {
            AxisMarks { value in
                AxisValueLabel {
                    if let v = value.as(String.self) {
                        Text(v)
                            .font(.caption2)
                    }
                }
            }
        }
    }
    
    // MARK: - Category Breakdown Section
    
    private var categoryBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Spending by Category")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            // Period picker
            Picker("Period", selection: $viewModel.selectedBreakdownPeriod) {
                ForEach(InsightsViewModel.BreakdownPeriod.allCases) { period in
                    Text(period.rawValue).tag(period)
                }
            }
            .pickerStyle(.segmented)
            
            if let data = viewModel.currentBreakdownData {
                categoryDonutChart(data: data)
                categoryLegend(data: data)
            } else if viewModel.isBreakdownLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 200)
            } else if let error = viewModel.breakdownError {
                ContentUnavailableView(error, systemImage: "exclamationmark.triangle")
            } else {
                ContentUnavailableView("No data available", systemImage: "chart.pie")
                    .frame(minHeight: 200)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }
    
    private func categoryDonutChart(data: (netExpense: Double, netByCategory: [String: Double], countByCategory: [String: Int])) -> some View {
        let sorted = data.netByCategory.sorted { $0.value > $1.value }
        let total = data.netExpense
        
        return Chart(sorted, id: \.key) { item in
            SectorMark(
                angle: .value("Amount", max(item.value, 0)),
                innerRadius: .ratio(0.6),
                angularInset: 1.5
            )
            .foregroundStyle(colorForCategory(item.key))
            .annotation(position: .overlay) {
                if total > 0 && item.value / total > 0.08 {
                    Text(String(format: "%.0f%%", (item.value / total) * 100))
                        .font(.caption2.bold())
                        .foregroundStyle(.white)
                }
            }
        }
        .frame(height: 220)
        .chartBackground { _ in
            VStack {
                Text(formatCurrency(total))
                    .font(.title3.bold())
                Text("Total")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private func categoryLegend(data: (netExpense: Double, netByCategory: [String: Double], countByCategory: [String: Int])) -> some View {
        let sorted = data.netByCategory.sorted { $0.value > $1.value }
        let total = data.netExpense
        
        return VStack(spacing: 8) {
            ForEach(sorted, id: \.key) { item in
                HStack {
                    Circle()
                        .fill(colorForCategory(item.key))
                        .frame(width: 10, height: 10)
                    
                    if let cat = Category(rawValue: item.key) {
                        Text(cat.emoji + " " + cat.displayName)
                            .font(.subheadline)
                    } else {
                        Text(item.key)
                            .font(.subheadline)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text(formatCurrency(item.value))
                            .font(.subheadline.weight(.medium))
                        
                        HStack(spacing: 4) {
                            if total > 0 {
                                Text(String(format: "%.1f%%", (item.value / total) * 100))
                            }
                            if let count = data.countByCategory[item.key] {
                                Text("• \(count) txns")
                            }
                        }
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "CAD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$\(Int(value))"
    }
    
    private func compactCurrency(_ value: Double) -> String {
        if value >= 1000 {
            return "$\(Int(value / 1000))k"
        }
        return "$\(Int(value))"
    }
    
    private func monthDisplayName(_ monthStr: String) -> String {
        // "2026-02" -> "February"
        let parts = monthStr.split(separator: "-")
        guard parts.count == 2, let monthNum = Int(parts[1]) else { return monthStr }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        var comps = DateComponents()
        comps.month = monthNum
        if let date = Calendar.current.date(from: comps) {
            return formatter.string(from: date)
        }
        return monthStr
    }
    
    private func shortMonth(_ monthStr: String) -> String {
        // "2026-02" -> "Feb"
        let parts = monthStr.split(separator: "-")
        guard parts.count == 2, let monthNum = Int(parts[1]) else { return monthStr }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        var comps = DateComponents()
        comps.month = monthNum
        if let date = Calendar.current.date(from: comps) {
            return formatter.string(from: date)
        }
        return monthStr
    }
    
    private func colorForCategory(_ key: String) -> Color {
        if let cat = Category(rawValue: key) {
            return cat.color
        }
        // Fallback for unknown categories
        return .gray
    }
}

#Preview {
    InsightsView()
}
