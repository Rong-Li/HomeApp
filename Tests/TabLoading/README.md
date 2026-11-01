# Tab loading checks

Run `rtk bash Tests/TabLoading/run.sh` from the repository root with Xcode installed.
The checks compile the production loader without credentials or network access.
They cover reuse, expiration, manual refresh, failed-load retries, and an active
load surviving tab changes without duplicate requests.

The simulator reproduction used the actual tab views/API service with intercepted
offline responses and 4,000 fake transactions. Three round trips originally added
27 requests; with tab reuse they added none. Month transaction loading is now
separate and occurs only on selection, with that month's bounds and a cached result.
