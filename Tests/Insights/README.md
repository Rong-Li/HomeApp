# Offline Insights regression checks

From the HomeApp repository root on macOS with Xcode installed:

```sh
rtk bash Tests/Insights/run.sh
```

The script compiles production models and `InsightsViewModel` into a temporary
executable. `OfflineAPIService.swift` replaces the network boundary with configured
fixtures; unconfigured report/trend loads fail immediately. Credentials are not compiled.

Checks cover both category toggles (including selected-category filters), trend
and pie total parity, month/period transitions, missing months, January category
availability, and older/partial API responses. Transaction-based monthly details
load only after selection, use one month's bounds, and reuse cached results.
Refunds, cents, empty months, request failures, and partial refresh failures are covered.
Failures return a nonzero status.
These are state/serialization checks; verify chart appearance in the simulator.
