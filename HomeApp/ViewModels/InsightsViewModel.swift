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
    @Published private(set) var isMonthLoading = false
    @Published private var selectedMonthSnapshot: CategorySnapshotMonth?
    private var monthCache: [String: CategorySnapshotMonth] = [:]
    private var breakdownDate = Date()
    
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
        if let months = breakdownResponse?.currentYearMonths, !months.isEmpty {
            return months.map(\.month).sorted(by: >)
        }
        let parts = currentMonthKey.split(separator: "-")
        guard parts.count == 2, let month = Int(parts[1]), (1...12).contains(month) else { return [] }
        return (1...month).reversed().map { String(format: "%@-%02d", String(parts[0]), $0) }
    }

    private var currentMonthKey: String {
        if let month = breakdownResponse?.currentMonth?.month ?? trendResponse?.currentMonth.month { return month }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return String(format: "%04d-%02d", calendar.component(.year, from: breakdownDate), calendar.component(.month, from: breakdownDate))
    }

    var selectedBreakdownError: String? {
        selectedBreakdownMonth != nil ? monthlyBreakdownError : breakdownError
    }

    var isMonthlyBreakdownUnavailable: Bool {
        guard let breakdown = breakdownResponse else { return false }
        if let month = selectedBreakdownMonth {
            return selectedMonthSnapshot?.month != month && !isMonthLoading
        }
        return selectedBreakdownPeriod == .currentMonth && monthCache[currentMonthKey] == nil &&
            breakdown.currentMonth == nil && breakdown.currentYearMonths?.contains(where: { $0.month == currentMonthKey }) != true
    }

    func selectBreakdownMonth(_ month: String?) {
        selectedBreakdownMonth = month
        monthlyBreakdownError = nil
        isMonthLoading = false
        selectedMonthSnapshot = month.flatMap { key in
            monthCache[key] ?? breakdownResponse?.currentYearMonths?.first(where: { $0.month == key })
        }
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
        // Spending breakdowns omit earnings, so keep Salary available explicitly.
        var cats: Set<String> = [Category.salary.rawValue]
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
            guard let data = selectedMonthSnapshot, data.month == month else { return nil }
            raw = (data.netExpense, data.netByCategory, data.countByCategory)
        } else {
            switch selectedBreakdownPeriod {
            case .currentMonth:
                guard let data = monthCache[currentMonthKey] ?? breakdown.currentMonth ??
                    breakdown.currentYearMonths?.first(where: { $0.month == currentMonthKey }) else { return nil }
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
            return currentMonthKey
        case .currentYear:
            return breakdown.currentYear?.year ?? ""
        case .lastYear:
            return breakdown.lastYear?.year ?? ""
        }
    }
    
    // MARK: - Data Loading
    
    @discardableResult
    func loadAllData() async -> Bool {
        await withTaskGroup(of: Bool.self) { group in
            group.addTask { await self.loadTrend() }
            group.addTask { await self.loadHousingTrend() }
            group.addTask { await self.loadInvestmentTrend() }
            group.addTask { await self.loadBreakdown() }
            return await group.reduce(true) { $0 && $1 }
        }
    }
    
    @discardableResult
    func loadTrend() async -> Bool {
        isTrendLoading = true
        trendError = nil
        defer { isTrendLoading = false }
        
        do {
            trendResponse = try await APIService.shared.fetchSpendingTrend(
                months: selectedMonths,
                category: selectedCategory
            )
            return true
        } catch {
            trendError = "Failed to load spending trend"
            #if DEBUG
            print("[InsightsVM] Trend error: \(error)")
            #endif
            return false
        }
    }
    
    @discardableResult
    func loadBreakdown(asOf date: Date = Date()) async -> Bool {
        isBreakdownLoading = true
        breakdownError = nil
        breakdownDate = date
        defer { isBreakdownLoading = false }
        
        do {
            breakdownResponse = try await APIService.shared.fetchCategoryBreakdown()
            if let month = selectedBreakdownMonth, !availableBreakdownMonths.contains(month) {
                selectBreakdownMonth(nil)
            }
            return true
        } catch {
            breakdownError = "Failed to load category breakdown"
            #if DEBUG
            print("[InsightsVM] Breakdown error: \(error)")
            #endif
            return false
        }
    }

    @discardableResult
    func loadSelectedMonth(force: Bool = false) async -> Bool {
        guard let month = selectedBreakdownMonth else { return true }
        if !force, let snapshot = monthCache[month] ?? breakdownResponse?.currentYearMonths?.first(where: { $0.month == month }) {
            selectedMonthSnapshot = snapshot
            return true
        }
        let parts = month.split(separator: "-")
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        guard availableBreakdownMonths.contains(month), parts.count == 2,
              let year = Int(parts[0]), let number = Int(parts[1]),
              let start = calendar.date(from: DateComponents(year: year, month: number, day: 1)),
              let next = calendar.date(byAdding: .month, value: 1, to: start) else { return false }
        isMonthLoading = true
        monthlyBreakdownError = nil
        defer { if selectedBreakdownMonth == month { isMonthLoading = false } }
        do {
            let transactions = try await APIService.shared.fetchTransactions(startDate: start, endDate: next.addingTimeInterval(-1))
            guard !Task.isCancelled else { return false }
            let response = breakdownResponse ?? CategoryBreakdownResponse(lastMonth: nil, currentYear: nil, lastYear: nil,
                                                                          currentMonth: nil, currentYearMonths: nil)
            let snapshot = response.withMonthlySnapshots(from: transactions, through: start).currentMonth
            guard let snapshot else { return false }
            if breakdownResponse == nil { breakdownResponse = response }
            monthCache[month] = snapshot
            if selectedBreakdownMonth == month { selectedMonthSnapshot = snapshot }
            return true
        } catch {
            if !Task.isCancelled && selectedBreakdownMonth == month {
                monthlyBreakdownError = "Failed to load monthly spending. Try again."
            }
            return false
        }
    }
    
    func onMonthsChanged(_ months: Int) async {
        selectedMonths = months
        await withTaskGroup(of: Void.self) { group in
            group.addTask { _ = await self.loadTrend() }
            group.addTask { _ = await self.loadHousingTrend() }
            group.addTask { _ = await self.loadInvestmentTrend() }
        }
    }
    
    func onCategoryChanged(_ category: String?) async {
        selectedCategory = category
        await loadTrend()
    }
    
    @discardableResult
    func loadHousingTrend() async -> Bool {
        do {
            housingTrendResponse = try await APIService.shared.fetchSpendingTrend(
                months: selectedMonths,
                category: Category.housing.rawValue
            )
            return true
        } catch {
            #if DEBUG
            print("[InsightsVM] Housing trend error: \(error)")
            #endif
            return false
        }
    }

    @discardableResult
    func loadInvestmentTrend() async -> Bool {
        do {
            investmentTrendResponse = try await APIService.shared.fetchSpendingTrend(
                months: selectedMonths,
                category: Category.investment.rawValue
            )
            return true
        } catch {
            #if DEBUG
            print("[InsightsVM] Investment trend error: \(error)")
            #endif
            return false
        }
    }
}
