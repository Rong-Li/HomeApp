# Insights chart updates

Approved in conversation on 2026-10-31.

- Give bar-chart Y-axis labels the same visual weight as X-axis labels; remove 18M.
- Investment and Housing independently control both charts, totals, percentages,
  and legends, including when both or neither are selected.
- Add a month menu to the right of Spending by Category, offering January through
  the current month of the current year, newest first. Default to no explicit
  month selection, with no None option; period buttons clear the month override.
- Replace Last Month with Current Month; retain This Year and Last Year.
- Selecting a month overrides the period control. Selecting a period clears the
  month override. Empty periods show an explicit empty state instead of an empty pie.
- Extend the breakdown API with current_month and current_year_months, retaining
  existing fields for older clients. Use the existing report data source.

Approaches considered: API monthly snapshots (chosen for consistent report
semantics) or client transaction aggregation (rejected because it duplicates
reporting logic). Future months are omitted; months without reports are zero/empty
snapshots. Do not silently show a different period. Do not deploy or access live
financial services.

Compatibility follow-up after the user reported a disabled Month menu: when an
older or partial API response omits monthly snapshots, keep the month menu available
from the calendar. Fetch only the selected month's data after it is clicked,
through the existing expense endpoint, and cache its UTC expense snapshot.
Use Decimal debit-minus-credit sums and exclude earning categories. Both default
Current Month and the matching menu month must use the same snapshot. Keep usable
yearly reports available if the monthly fallback fails. Updated API responses
continue to use report snapshots without an extra transaction request.
Do not fetch transaction history automatically when Insights appears. Report data
still loads normally. Reuse recent tab loads for 60 seconds and share active loads;
manual refresh bypasses freshness. During month loading, monthly data is based on transactions while trend/yearly
views retain stored reports, so aggregation freshness may cause differences.
