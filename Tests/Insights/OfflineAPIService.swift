import Foundation

// Test-only network boundary. A regression check must not make HTTP requests.
actor APIService {
    static let shared = APIService()
    var breakdown: CategoryBreakdownResponse?
    var transactions: [Transaction] = []
    var transactionRange: (start: Date, end: Date)?
    var failTransactions = false

    func configure(breakdown: CategoryBreakdownResponse, transactions: [Transaction], failTransactions: Bool = false) {
        self.breakdown = breakdown
        self.transactions = transactions
        self.failTransactions = failTransactions
        transactionRange = nil
    }

    func fetchSpendingTrend(months: Int, category: String?) async throws -> TrendResponse {
        fatalError("Unexpected data load in offline Insights checks")
    }

    func fetchCategoryBreakdown() async throws -> CategoryBreakdownResponse {
        guard let breakdown else { fatalError("Unexpected data load in offline Insights checks") }
        return breakdown
    }

    func fetchTransactions(startDate: Date, endDate: Date) async throws -> [Transaction] {
        transactionRange = (startDate, endDate)
        if failTransactions { throw URLError(.notConnectedToInternet) }
        return transactions
    }
}
