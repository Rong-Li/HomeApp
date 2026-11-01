import Foundation

// Test-only network boundary. A regression check must not make HTTP requests.
actor APIService {
    static let shared = APIService()
    var breakdown: CategoryBreakdownResponse?
    var transactions: [Transaction] = []
    var transactionRange: (start: Date, end: Date)?
    var transactionRequestCount = 0
    var failTransactions = false
    var trend: TrendResponse?
    var failingTrendCategories: Set<String> = []

    func configureTrends(_ trend: TrendResponse, failing categories: Set<String> = []) {
        self.trend = trend
        failingTrendCategories = categories
    }

    func configure(breakdown: CategoryBreakdownResponse, transactions: [Transaction], failTransactions: Bool = false) {
        self.breakdown = breakdown
        self.transactions = transactions
        self.failTransactions = failTransactions
        transactionRange = nil
        transactionRequestCount = 0
    }

    func fetchSpendingTrend(months: Int, category: String?) async throws -> TrendResponse {
        guard let trend else { fatalError("Unexpected data load in offline Insights checks") }
        if failingTrendCategories.contains(category ?? "All") { throw URLError(.cannotConnectToHost) }
        return trend
    }

    func fetchCategoryBreakdown() async throws -> CategoryBreakdownResponse {
        guard let breakdown else { fatalError("Unexpected data load in offline Insights checks") }
        return breakdown
    }

    func fetchTransactions(startDate: Date, endDate: Date) async throws -> [Transaction] {
        transactionRequestCount += 1
        transactionRange = (startDate, endDate)
        if failTransactions { throw URLError(.notConnectedToInternet) }
        return transactions
    }
}
