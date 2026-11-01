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
    @Published var selectedBreakdownPeriod: BreakdownPeriod = .currentMonth
    @Published private(set) var selectedBreakdownMonth: String?
    @Published var isBreakdownLoading = false
    @Published var breakdownError: String?
    @Published var monthlyBreakdownError: String?
    
    // Housing filter (default: exclude housing)
    @Published var includeHousing: Bool = false
    // Investment filter (default: exclude investment)
    @Published var includeInvestment: Bool = false
    
    enum BreakdownPeriod: String, CaseIterable, Identifiable {
        case currentMonth = "Current Month"
        case currentYear = "This Year"
        case lastYear = "Last Year"
        
        var id: String { rawValue }
    }
    
    // MARK: - Computed Properties

    var availableBreakdownMonths: [String] {
        breakdownResponse?.currentYearMonths?.map(\.month).sorted(by: >) ?? []
    }

    var selectedBreakdownError: String? {
        if let breakdownError { return breakdownError }
        return selectedBreakdownMonth != nil || selectedBreakdownPeriod == .currentMonth ? monthlyBreakdownError : nil
    }

    var isMonthlyBreakdownUnavailable: Bool {
        guard let breakdown = breakdownResponse else { return false }
        if let month = selectedBreakdownMonth {
            return breakdown.currentYearMonths?.contains(where: { $0.month == month }) != true
        }
        return selectedBreakdownPeriod == .currentMonth && breakdown.currentMonth == nil
    }

    func selectBreakdownMonth(_ month: String?) {
        selectedBreakdownMonth = month
        if month == nil {
            selectedBreakdownPeriod = .currentMonth
        }
    }

    func selectBreakdownPeriod(_ period: BreakdownPeriod) {
        selectedBreakdownMonth = nil
        selectedBreakdownPeriod = period
    }
    
    var availableCategories: [String] {
        guard trendResponse != nil else { return [] }
        // Collect unique categories from all trend data
        var cats = Set<String>()
        // We derive categories from the breakdown response if available
        if let breakdown = breakdownResponse {
            if let lastMonth = breakdown.lastMonth {
                cats.formUnion(lastMonth.netByCategory.keys)
            }
            if let lm = breakdown.currentMonth {
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
        if isSelectedCategoryExcluded { return 0 }
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
        if isSelectedCategoryExcluded {
            return allEntries.map { TrendMonthEntry(month: $0.month, netExpense: 0) }
        }
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

    private var isSelectedCategoryExcluded: Bool {
        (selectedCategory == Category.housing.rawValue && !includeHousing) ||
        (selectedCategory == Category.investment.rawValue && !includeInvestment)
    }
    
    var currentBreakdownData: (netExpense: Double, netByCategory: [String: Double], countByCategory: [String: Int])? {
        guard let breakdown = breakdownResponse else { return nil }
        
        let raw: (netExpense: Double, netByCategory: [String: Double], countByCategory: [String: Int])?
        
        if let month = selectedBreakdownMonth {
            guard let data = breakdown.currentYearMonths?.first(where: { $0.month == month }) else { return nil }
            raw = (data.netExpense, data.netByCategory, data.countByCategory)
        } else {
            switch selectedBreakdownPeriod {
            case .currentMonth:
                guard let data = breakdown.currentMonth else { return nil }
                raw = (data.netExpense, data.netByCategory, data.countByCategory)
            case .currentYear:
                guard let data = breakdown.currentYear else { return nil }
                raw = (data.netExpense, data.netByCategory, data.countByCategory)
            case .lastYear:
                guard let data = breakdown.lastYear else { return nil }
                raw = (data.netExpense, data.netByCategory, data.countByCategory)
            }
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
        if let month = selectedBreakdownMonth {
            return month
        }
        
        switch selectedBreakdownPeriod {
        case .currentMonth:
            return breakdown.currentMonth?.month ?? ""
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
    
    func loadBreakdown(asOf date: Date = Date()) async {
        isBreakdownLoading = true
        breakdownError = nil
        monthlyBreakdownError = nil
        
        do {
            var response = try await APIService.shared.fetchCategoryBreakdown()
            if response.currentMonth == nil || response.currentYearMonths?.isEmpty != false {
                // Older API deployments do not have monthly report snapshots yet.
                var calendar = Calendar(identifier: .gregorian)
                calendar.timeZone = TimeZone(secondsFromGMT: 0)!
                let startDate = calendar.dateInterval(of: .year, for: date)!.start
                do {
                    let transactions = try await APIService.shared.fetchTransactions(startDate: startDate, endDate: date)
                    response = response.withMonthlySnapshots(from: transactions, through: date)
                } catch {
                    monthlyBreakdownError = "Failed to load monthly spending. Try again."
                }
            }
            breakdownResponse = response
            if let month = selectedBreakdownMonth, !availableBreakdownMonths.contains(month) {
                selectBreakdownMonth(nil)
            }
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
