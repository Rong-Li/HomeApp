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
    @Published var housingTrendResponse: TrendResponse?
    @Published var investmentTrendResponse: TrendResponse?
    @Published var selectedMonths: Int = 6
    @Published var selectedCategory: String? = nil
    @Published var isTrendLoading = false
    @Published var trendError: String?
    
    // MARK: - Category Breakdown State
    
    @Published var breakdownResponse: CategoryBreakdownResponse?
    @Published var selectedBreakdownPeriod: BreakdownPeriod = .lastMonth
    @Published var isBreakdownLoading = false
    @Published var breakdownError: String?
    
    // Housing filter (default: exclude housing)
    @Published var includeHousing: Bool = false
    // Investment filter (default: exclude investment)
    @Published var includeInvestment: Bool = false
    
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
    
    /// Current month net expense adjusted for housing and investment toggles
    var adjustedCurrentMonthExpense: Double? {
        guard let current = trendResponse?.currentMonth else { return nil }
        var expense = current.netExpense
        if selectedCategory == nil {
            if !includeHousing {
                expense -= housingTrendResponse?.currentMonth.netExpense ?? 0
            }
            if !includeInvestment {
                expense -= investmentTrendResponse?.currentMonth.netExpense ?? 0
            }
        }
        return expense
    }
    
    /// Trend entries adjusted for housing and investment toggles
    var adjustedTrendEntries: [TrendMonthEntry]? {
        guard let trend = trendResponse else { return nil }
        let allEntries = trend.trend + [
            TrendMonthEntry(month: trend.currentMonth.month, netExpense: trend.currentMonth.netExpense)
        ]
        guard selectedCategory == nil else { return allEntries }

        // Build subtraction maps for excluded large-amount categories
        var subtractionByMonth: [String: Double] = [:]

        if !includeHousing, let housingTrend = housingTrendResponse {
            let housingEntries = housingTrend.trend + [
                TrendMonthEntry(month: housingTrend.currentMonth.month, netExpense: housingTrend.currentMonth.netExpense)
            ]
            for entry in housingEntries {
                subtractionByMonth[entry.month, default: 0] += entry.netExpense
            }
        }

        if !includeInvestment, let investmentTrend = investmentTrendResponse {
            let investmentEntries = investmentTrend.trend + [
                TrendMonthEntry(month: investmentTrend.currentMonth.month, netExpense: investmentTrend.currentMonth.netExpense)
            ]
            for entry in investmentEntries {
                subtractionByMonth[entry.month, default: 0] += entry.netExpense
            }
        }

        return allEntries.map { entry in
            TrendMonthEntry(month: entry.month, netExpense: entry.netExpense - (subtractionByMonth[entry.month] ?? 0))
        }
    }
    
    var currentBreakdownData: (netExpense: Double, netByCategory: [String: Double], countByCategory: [String: Int])? {
        guard let breakdown = breakdownResponse else { return nil }
        
        let raw: (netExpense: Double, netByCategory: [String: Double], countByCategory: [String: Int])?
        
        switch selectedBreakdownPeriod {
        case .lastMonth:
            guard let data = breakdown.lastMonth else { return nil }
            raw = (data.netExpense, data.netByCategory, data.countByCategory)
        case .currentYear:
            guard let data = breakdown.currentYear else { return nil }
            raw = (data.netExpense, data.netByCategory, data.countByCategory)
        case .lastYear:
            guard let data = breakdown.lastYear else { return nil }
            raw = (data.netExpense, data.netByCategory, data.countByCategory)
        }
        
        guard var result = raw else { return nil }
        
        if !includeHousing {
            let housingKey = Category.housing.rawValue
            let housingAmount = result.netByCategory[housingKey] ?? 0
            result.netByCategory.removeValue(forKey: housingKey)
            result.countByCategory.removeValue(forKey: housingKey)
            result.netExpense -= housingAmount
        }

        if !includeInvestment {
            let investmentKey = Category.investment.rawValue
            let investmentAmount = result.netByCategory[investmentKey] ?? 0
            result.netByCategory.removeValue(forKey: investmentKey)
            result.countByCategory.removeValue(forKey: investmentKey)
            result.netExpense -= investmentAmount
        }
        
        return result
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
            group.addTask { await self.loadHousingTrend() }
            group.addTask { await self.loadInvestmentTrend() }
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
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadTrend() }
            group.addTask { await self.loadHousingTrend() }
            group.addTask { await self.loadInvestmentTrend() }
        }
    }
    
    func onCategoryChanged(_ category: String?) async {
        selectedCategory = category
        await loadTrend()
    }
    
    func loadHousingTrend() async {
        do {
            housingTrendResponse = try await APIService.shared.fetchSpendingTrend(
                months: selectedMonths,
                category: Category.housing.rawValue
            )
        } catch {
            #if DEBUG
            print("[InsightsVM] Housing trend error: \(error)")
            #endif
        }
    }

    func loadInvestmentTrend() async {
        do {
            investmentTrendResponse = try await APIService.shared.fetchSpendingTrend(
                months: selectedMonths,
                category: Category.investment.rawValue
            )
        } catch {
            #if DEBUG
            print("[InsightsVM] Investment trend error: \(error)")
            #endif
        }
    }
}
