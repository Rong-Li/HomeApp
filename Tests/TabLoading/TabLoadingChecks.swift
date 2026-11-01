import Foundation

@main
struct TabLoadingChecks {
    @MainActor
    static func main() async {
        var failures = 0
        func check(_ condition: Bool, _ message: String) {
            if !condition { failures += 1; print("FAIL: \(message)") }
        }

        var now: TimeInterval = 100
        var requests = 0
        let loader = TabDataLoader(now: { now })
        let fetch: @MainActor () async -> Bool = { requests += 1; return true }
        await loader.loadIfNeeded(operation: fetch)
        await loader.loadIfNeeded(operation: fetch)
        check(requests == 1, "Returning to a loaded tab must reuse its data")
        now += 59
        await loader.loadIfNeeded(operation: fetch)
        check(requests == 1, "Fresh tab data must not be fetched again")
        now += 1
        await loader.loadIfNeeded(operation: fetch)
        check(requests == 2, "Expired tab data must refresh")
        await loader.loadIfNeeded(force: true, operation: fetch)
        check(requests == 3, "Pull to refresh must bypass freshness")

        var attempts = 0
        let retryLoader = TabDataLoader()
        await retryLoader.loadIfNeeded { attempts += 1; return false }
        await retryLoader.loadIfNeeded { attempts += 1; return true }
        check(attempts == 2, "Failed loads must be retried on the next visit")
        await retryLoader.loadIfNeeded(force: true) { attempts += 1; return false }
        await retryLoader.loadIfNeeded { attempts += 1; return true }
        check(attempts == 4, "A failed forced refresh must invalidate the previous successful timestamp")

        var starts = 0
        var completion: CheckedContinuation<Bool, Never>?
        let sharedLoader = TabDataLoader()
        let first = Task { @MainActor in
            await sharedLoader.loadIfNeeded {
                starts += 1
                return await withCheckedContinuation { completion = $0 }
            }
        }
        for _ in 0..<1000 {
            if completion != nil { break }
            await Task.yield()
        }
        guard let completion else { fatalError("Initial load did not start") }
        first.cancel()
        let second = Task { @MainActor in
            await sharedLoader.loadIfNeeded { starts += 1; return true }
        }
        await Task.yield()
        completion.resume(returning: true)
        await first.value
        await second.value
        await sharedLoader.loadIfNeeded { starts += 1; return true }
        check(starts == 1, "Switching away must not cancel or duplicate an active data load")

        if failures > 0 { exit(1) }
        print("Tab loading checks passed: cache reuse, expiration, refresh, retry, and cancellation/coalescing")
    }
}
