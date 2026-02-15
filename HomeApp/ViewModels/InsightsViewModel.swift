//
//  InsightsViewModel.swift
//  HomeApp
//
//  ViewModel for the Insights tab
//

import Combine
import Foundation

@MainActor
class InsightsViewModel: ObservableObject {
    
    // MARK: - Spending Trend State
    
    @Published var trendResponse: TrendResponse?
    @Published var selectedMonths: Int = 6
    @Published var selectedCategory: String? = nil
    @Published var isTrendLoading = false
    @Published var trendError: String?
    
    // MARK: - Category Breakdown State
    
    @Published var breakdownResponse: CategoryBreakdownResponse?
    @Published var selectedBreakdownPeriod: BreakdownPeriod = .lastMonth
    @Published var isBreakdownLoading = false
    @Published var breakdownError: String?
    
    enum BreakdownPeriod: String, CaseIterable, Identifiable {
        case lastMonth = "Last Month"
        case currentYear = "This Year"
        case lastYear = "Last Year"
        
        var id: String { rawValue }
    }
    
    // MARK: - Computed Properties
    
    var availableCategories: [String] {
        guard let trend = trendResponse else { return [] }
        // Collect unique categories from all trend data
        var cats = Set<String>()
        // We derive categories from the breakdown response if available
        if let breakdown = breakdownResponse {
            if let lm = breakdown.lastMonth {
                cats.formUnion(lm.netByCategory.keys)
            }
            if let cy = breakdown.currentYear {
                cats.formUnion(cy.netByCategory.keys)
            }
        }
        return cats.sorted()
    }
    
    var currentBreakdownData: (netExpense: Double, netByCategory: [String: Double], countByCategory: [String: Int])? {
        guard let breakdown = breakdownResponse else { return nil }
        
        switch selectedBreakdownPeriod {
        case .lastMonth:
            guard let data = breakdown.lastMonth else { return nil }
            return (data.netExpense, data.netByCategory, data.countByCategory)
        case .currentYear:
            guard let data = breakdown.currentYear else { return nil }
            return (data.netExpense, data.netByCategory, data.countByCategory)
        case .lastYear:
            guard let data = breakdown.lastYear else { return nil }
            return (data.netExpense, data.netByCategory, data.countByCategory)
        }
    }
    
    var breakdownLabel: String {
        guard let breakdown = breakdownResponse else { return "" }
        
        switch selectedBreakdownPeriod {
        case .lastMonth:
            return breakdown.lastMonth?.month ?? ""
        case .currentYear:
            return breakdown.currentYear?.year ?? ""
        case .lastYear:
            return breakdown.lastYear?.year ?? ""
        }
    }
    
    // MARK: - Data Loading
    
    func loadAllData() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadTrend() }
            group.addTask { await self.loadBreakdown() }
        }
    }
    
    func loadTrend() async {
        isTrendLoading = true
        trendError = nil
        
        do {
            trendResponse = try await APIService.shared.fetchSpendingTrend(
                months: selectedMonths,
                category: selectedCategory
            )
        } catch {
            trendError = "Failed to load spending trend"
            #if DEBUG
            print("[InsightsVM] Trend error: \(error)")
            #endif
        }
        
        isTrendLoading = false
    }
    
    func loadBreakdown() async {
        isBreakdownLoading = true
        breakdownError = nil
        
        do {
            breakdownResponse = try await APIService.shared.fetchCategoryBreakdown()
        } catch {
            breakdownError = "Failed to load category breakdown"
            #if DEBUG
            print("[InsightsVM] Breakdown error: \(error)")
            #endif
        }
        
        isBreakdownLoading = false
    }
    
    func onMonthsChanged(_ months: Int) async {
        selectedMonths = months
        await loadTrend()
    }
    
    func onCategoryChanged(_ category: String?) async {
        selectedCategory = category
        await loadTrend()
    }
}
