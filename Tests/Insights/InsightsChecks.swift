import Foundation

// Runs real models/view-model behavior with an offline network boundary.
@main
struct InsightsChecks {
    private static var failures = 0

    private static func check(_ condition: @autoclosure () -> Bool, _ message: String = "Assertion failed", line: UInt = #line) {
        if !condition() {
            failures += 1
            print("FAIL at line \(line): \(message)")
        }
    }

    @MainActor
    static func main() async throws {
        let fixture = Data("""
        {
          "last_month": {"month":"2026-02","net_expense":70,"net_by_category":{"Groceries":70},"count_by_category":{"Groceries":1}},
          "current_month": {"month":"2026-03","net_expense":1550,"net_by_category":{"Groceries":100,"Investment":450,"Housing":1000},"count_by_category":{"Groceries":1,"Investment":2,"Housing":1}},
          "current_year_months": [
            {"month":"2026-01","net_expense":0,"net_by_category":{},"count_by_category":{}},
            {"month":"2026-02","net_expense":70,"net_by_category":{"Groceries":70},"count_by_category":{"Groceries":1}},
            {"month":"2026-03","net_expense":1550,"net_by_category":{"Groceries":100,"Investment":450,"Housing":1000},"count_by_category":{"Groceries":1,"Investment":2,"Housing":1}}
          ],
          "current_year": {"year":"2026","net_expense":1620,"net_by_category":{"Groceries":170,"Investment":450,"Housing":1000},"count_by_category":{"Groceries":2,"Investment":2,"Housing":1}},
          "last_year": null
        }
        """.utf8)
        let model = InsightsViewModel()
        model.breakdownResponse = try JSONDecoder().decode(CategoryBreakdownResponse.self, from: fixture)
        model.trendResponse = TrendResponse(
            monthsRequested: 6, categoryFilter: nil,
            currentMonth: CurrentMonthSummary(month: "2026-03", netExpense: 1550, daysRemaining: 21),
            previousMonthEarning: 5000, trend: [TrendMonthEntry(month: "2026-02", netExpense: 70)]
        )
        model.housingTrendResponse = TrendResponse(
            monthsRequested: 6, categoryFilter: "Housing",
            currentMonth: CurrentMonthSummary(month: "2026-03", netExpense: 1000, daysRemaining: 21),
            previousMonthEarning: 5000, trend: []
        )
        model.investmentTrendResponse = TrendResponse(
            monthsRequested: 6, categoryFilter: "Investment",
            currentMonth: CurrentMonthSummary(month: "2026-03", netExpense: 450, daysRemaining: 21),
            previousMonthEarning: 5000, trend: []
        )
        for (housing, investment, total, categories) in [
            (false, false, 100.0, Set(["Groceries"])),
            (false, true, 550.0, Set(["Groceries", "Investment"])),
            (true, false, 1100.0, Set(["Groceries", "Housing"])),
            (true, true, 1550.0, Set(["Groceries", "Housing", "Investment"]))
        ] {
            model.includeHousing = housing
            model.includeInvestment = investment
            guard let breakdown = model.currentBreakdownData else {
                fatalError("Current month snapshot should be available")
            }
            check(breakdown.netExpense == total, "Wrong current-month total for Housing=\(housing), Investment=\(investment): \(breakdown.netExpense)")
            check(Set(breakdown.netByCategory.keys) == categories)
            check(Set(breakdown.countByCategory.keys) == categories)
            check(model.adjustedCurrentMonthExpense == total)
            check(model.adjustedTrendEntries?.last?.netExpense == total)
        }
        check(model.selectedBreakdownMonth == nil)
        check(model.availableBreakdownMonths == ["2026-03", "2026-02", "2026-01"])
        model.selectBreakdownMonth("2026-02")
        check(model.breakdownLabel == "2026-02")
        check(model.currentBreakdownData?.netExpense == 70)
        model.selectBreakdownPeriod(.currentYear)
        check(model.selectedBreakdownMonth == nil)
        check(model.currentBreakdownData?.netExpense == 1620)
        model.selectBreakdownMonth("2026-01")
        check(model.currentBreakdownData?.netExpense == 0)
        check(model.currentBreakdownData?.netByCategory.isEmpty == true)
        model.selectBreakdownPeriod(.currentMonth)
        check(model.selectedBreakdownMonth == nil)
        check(model.breakdownLabel == "2026-03")
        model.selectBreakdownPeriod(.lastYear)
        check(model.currentBreakdownData == nil)
        model.selectBreakdownMonth("2026-03")
        model.selectBreakdownMonth(nil)
        check(model.selectedBreakdownMonth == nil)
        check(model.selectedBreakdownPeriod == .currentMonth)
        check(model.currentBreakdownData?.netExpense == 1550)

        // A month override must not silently display a different period if unavailable.
        model.selectBreakdownMonth("2025-12")
        check(model.currentBreakdownData == nil)

        // A category filter must not override the page-wide inclusion toggles.
        model.selectedCategory = "Investment"
        model.trendResponse = model.investmentTrendResponse
        model.includeInvestment = false
        check(model.adjustedCurrentMonthExpense == 0)
        check(model.adjustedTrendEntries?.last?.netExpense == 0)
        model.includeInvestment = true
        check(model.adjustedCurrentMonthExpense == 450)
        model.selectedCategory = "Housing"
        model.trendResponse = model.housingTrendResponse
        model.includeHousing = false
        check(model.adjustedCurrentMonthExpense == 0)
        check(model.adjustedTrendEntries?.last?.netExpense == 0)
        model.includeHousing = true
        check(model.adjustedCurrentMonthExpense == 1000)

        let january = Data("""
        {"last_month":{"month":"2025-12","net_expense":70,"net_by_category":{"Groceries":70},"count_by_category":{"Groceries":1}},"current_month":{"month":"2026-01","net_expense":0,"net_by_category":{},"count_by_category":{}},"current_year":null,"last_year":null}
        """.utf8)
        model.breakdownResponse = try JSONDecoder().decode(CategoryBreakdownResponse.self, from: january)
        check(model.availableCategories.contains("Groceries"), "December categories must remain selectable in January")

        let legacy = Data("""
        {"last_month":{"month":"2026-02","net_expense":70,"net_by_category":{"Groceries":70},"count_by_category":{"Groceries":1}},"current_year":null,"last_year":null}
        """.utf8)
        model.breakdownResponse = try JSONDecoder().decode(CategoryBreakdownResponse.self, from: legacy)
        model.selectBreakdownPeriod(.currentMonth)
        check(model.currentBreakdownData == nil)
        check(model.isMonthlyBreakdownUnavailable)
        check(model.availableBreakdownMonths.isEmpty)

        // An older server must still provide a selectable month menu after loading.
        // The existing expense endpoint supplies monthly data during API rollout.
        let referenceDate = ISO8601DateFormatter().date(from: "2026-03-10T12:00:00Z")!
        let marchDate = ISO8601DateFormatter().date(from: "2026-03-02T12:00:00Z")!
        let februaryDate = ISO8601DateFormatter().date(from: "2026-02-28T23:59:59Z")!
        let transactions = [
            Transaction(id: "1", amount: 100, category: .groceries, transactionType: .debit, currency: .cad, createdAt: marchDate),
            Transaction(id: "2", amount: 500, category: .investment, transactionType: .debit, currency: .cad, createdAt: marchDate),
            Transaction(id: "3", amount: 50, category: .investment, transactionType: .credit, currency: .cad, createdAt: marchDate),
            Transaction(id: "4", amount: 1000, category: .housing, transactionType: .debit, currency: .cad, createdAt: marchDate),
            Transaction(id: "5", amount: 5000, category: .salary, transactionType: .credit, currency: .cad, createdAt: marchDate),
            Transaction(id: "6", amount: 70, category: .groceries, transactionType: .debit, currency: .cad, createdAt: februaryDate)
        ]
        let legacyResponse = try JSONDecoder().decode(CategoryBreakdownResponse.self, from: legacy)
        await APIService.shared.configure(breakdown: legacyResponse, transactions: transactions)
        let compatibilityModel = InsightsViewModel()
        await compatibilityModel.loadBreakdown(asOf: referenceDate)
        check(compatibilityModel.availableBreakdownMonths.contains("2026-02"), "Legacy API must not leave the month menu disabled")
        compatibilityModel.selectBreakdownMonth("2026-02")
        check(compatibilityModel.currentBreakdownData?.netExpense == 70, "Legacy month selection must display that month's spending")
        check(compatibilityModel.breakdownError == nil)
        check(compatibilityModel.availableBreakdownMonths == ["2026-03", "2026-02", "2026-01"])
        compatibilityModel.selectBreakdownMonth("2026-01")
        check(compatibilityModel.currentBreakdownData?.netExpense == 0)
        check(compatibilityModel.currentBreakdownData?.countByCategory.isEmpty == true)
        compatibilityModel.selectBreakdownPeriod(.currentMonth)
        for (housing, investment, total) in [(false, false, 100.0), (false, true, 550.0), (true, false, 1100.0), (true, true, 1550.0)] {
            compatibilityModel.includeHousing = housing
            compatibilityModel.includeInvestment = investment
            check(compatibilityModel.currentBreakdownData?.netExpense == total)
        }
        check(compatibilityModel.currentBreakdownData?.countByCategory["Investment"] == 2)
        check(compatibilityModel.currentBreakdownData?.netByCategory["Salary"] == nil)
        let range = await APIService.shared.transactionRange
        check(range?.start == ISO8601DateFormatter().date(from: "2026-01-01T00:00:00Z"))
        check(range?.end == referenceDate)

        // A new server already has snapshots: don't fetch transactions unnecessarily.
        let newResponse = try JSONDecoder().decode(CategoryBreakdownResponse.self, from: fixture)
        await APIService.shared.configure(breakdown: newResponse, transactions: [], failTransactions: true)
        await compatibilityModel.loadBreakdown(asOf: referenceDate)
        check(compatibilityModel.breakdownError == nil)
        check(compatibilityModel.currentBreakdownData?.netExpense == 1550)
        let newServerRange = await APIService.shared.transactionRange
        check(newServerRange == nil)

        // A completely empty year must still offer all elapsed months.
        await APIService.shared.configure(breakdown: legacyResponse, transactions: [])
        let emptyModel = InsightsViewModel()
        await emptyModel.loadBreakdown(asOf: referenceDate)
        check(emptyModel.availableBreakdownMonths == ["2026-03", "2026-02", "2026-01"])
        check(emptyModel.currentBreakdownData?.netByCategory.isEmpty == true)

        await APIService.shared.configure(breakdown: legacyResponse, transactions: [], failTransactions: true)
        let failedModel = InsightsViewModel()
        await failedModel.loadBreakdown(asOf: referenceDate)
        check(failedModel.selectedBreakdownError != nil, "A failed fallback must report an error rather than fabricate zero spending")
        check(!failedModel.isBreakdownLoading)

        let usableLegacy = CategoryBreakdownResponse(
            lastMonth: legacyResponse.lastMonth,
            currentYear: CategorySnapshotYear(year: "2026", netExpense: 70, netByCategory: ["Groceries": 70], countByCategory: ["Groceries": 1]),
            lastYear: nil, currentMonth: nil, currentYearMonths: nil
        )
        await APIService.shared.configure(breakdown: usableLegacy, transactions: [], failTransactions: true)
        let yearlyModel = InsightsViewModel()
        await yearlyModel.loadBreakdown(asOf: referenceDate)
        yearlyModel.selectBreakdownPeriod(.currentYear)
        check(yearlyModel.currentBreakdownData?.netExpense == 70, "Monthly fetch failure must preserve valid yearly snapshots")
        check(yearlyModel.selectedBreakdownError == nil)

        let partial = CategoryBreakdownResponse(
            lastMonth: nil, currentYear: nil, lastYear: nil,
            currentMonth: newResponse.currentMonth, currentYearMonths: nil
        )
        var changedTransaction = transactions[0]
        changedTransaction.amount = 150
        await APIService.shared.configure(breakdown: partial, transactions: [changedTransaction])
        let partialModel = InsightsViewModel()
        await partialModel.loadBreakdown(asOf: referenceDate)
        let partialCurrentTotal = partialModel.currentBreakdownData?.netExpense
        partialModel.selectBreakdownMonth("2026-03")
        check(partialModel.currentBreakdownData?.netExpense == partialCurrentTotal,
              "Current Month and selecting the same month must use the same fallback snapshot")
        check(partialCurrentTotal == 150)

        let missingCurrent = CategoryBreakdownResponse(
            lastMonth: nil, currentYear: nil, lastYear: nil,
            currentMonth: nil, currentYearMonths: newResponse.currentYearMonths
        )
        await APIService.shared.configure(breakdown: missingCurrent, transactions: [changedTransaction])
        let missingCurrentModel = InsightsViewModel()
        await missingCurrentModel.loadBreakdown(asOf: referenceDate)
        check(missingCurrentModel.currentBreakdownData?.netExpense == 150)
        missingCurrentModel.selectBreakdownMonth("2026-03")
        check(missingCurrentModel.currentBreakdownData?.netExpense == 150)

        // Keep refunds, exact cancellation, cents, and year boundaries faithful to reports.
        let januaryDate = ISO8601DateFormatter().date(from: "2027-01-05T12:00:00Z")!
        let decemberDate = ISO8601DateFormatter().date(from: "2026-12-31T23:59:59Z")!
        let januaryTransactions = [
            Transaction(id: "old", amount: 999, category: .groceries, transactionType: .debit, currency: .cad, createdAt: decemberDate),
            Transaction(id: "cents1", amount: Decimal(string: "0.10")!, category: .groceries, transactionType: .debit, currency: .cad, createdAt: januaryDate),
            Transaction(id: "cents2", amount: Decimal(string: "0.20")!, category: .groceries, transactionType: .debit, currency: .cad, createdAt: januaryDate),
            Transaction(id: "refund", amount: Decimal(string: "0.30")!, category: .groceries, transactionType: .credit, currency: .cad, createdAt: januaryDate),
            Transaction(id: "negative", amount: 50, category: .investment, transactionType: .credit, currency: .cad, createdAt: januaryDate),
            Transaction(id: "cents3", amount: Decimal(string: "10.25")!, category: .housing, transactionType: .debit, currency: .cad, createdAt: januaryDate)
        ]
        let januarySnapshot = legacyResponse.withMonthlySnapshots(from: januaryTransactions, through: januaryDate)
        check(januarySnapshot.currentYearMonths?.map(\.month) == ["2027-01"])
        check(januarySnapshot.currentMonth?.netExpense == -39.75)
        check(januarySnapshot.currentMonth?.netByCategory == ["Investment": -50, "Housing": 10.25])
        check(januarySnapshot.currentMonth?.countByCategory["Groceries"] == 3)

        if failures > 0 { exit(1) }
        print("Insights checks passed: category toggles, month selection, legacy API loading, partial/error responses, empty months, refunds, and year boundaries")
    }
}
