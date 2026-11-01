import Foundation

/// Reuses recent tab data and keeps an active load alive across tab changes.
@MainActor
final class TabDataLoader {
    private let refreshInterval: TimeInterval
    private let now: () -> TimeInterval
    private var lastSuccessfulLoad: TimeInterval?
    private var inFlight: Task<Bool, Never>?

    init(refreshInterval: TimeInterval = 60,
         now: @escaping () -> TimeInterval = { ProcessInfo.processInfo.systemUptime }) {
        self.refreshInterval = refreshInterval
        self.now = now
    }

    func loadIfNeeded(force: Bool = false, operation: @escaping @MainActor () async -> Bool) async {
        if let inFlight {
            _ = await inFlight.value
            return
        }
        if !force, let lastSuccessfulLoad, now() - lastSuccessfulLoad < refreshInterval {
            return
        }

        // SwiftUI cancels .task when its tab disappears. The shared load should
        // finish once, so returning to the tab can reuse its result.
        let task = Task { await operation() }
        inFlight = task
        let succeeded = await task.value
        lastSuccessfulLoad = succeeded ? now() : nil
        inFlight = nil
    }
}
