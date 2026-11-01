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
availability, and loading older/partial API responses through the transaction
fallback. Refunds, cents, empty years, and fallback failures are covered as well.
Failures return a nonzero status.
These are state/serialization checks; verify chart appearance in the simulator.
