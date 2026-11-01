# HomeApp

SwiftUI family finance app for transactions, expense logging, Insights, payment
schedules, cash, and balances. Investments and Settings are placeholders.
The Python AWS Lambda backend is in `../LambdaApps`; this repo is the iOS client.

## Project map

| Location | Responsibility |
| --- | --- |
| `HomeApp/HomeAppApp.swift`, `HomeApp/Views/MainTabView.swift` | App entry point and tab navigation |
| `HomeApp/Views/` | Screens grouped by feature; shared UI in `Components/` |
| `HomeApp/ViewModels/` | Feature state, loading, filtering, and actions |
| `HomeApp/Models/` | API types, enums, filters, and display helpers |
| `HomeApp/Services/APIService.swift` | Shared actor for HTTP, authentication, and serialization |
| `HomeApp/Services/TabDataLoader.swift` | Reuses recent tab loads and shares in-flight work |
| `HomeApp/Services/APIError.swift` | Network errors |
| `HomeApp/Services/NetworkMonitor.swift` | Connectivity state |
| `HomeApp/Services/LocationService.swift` | Optional postal-code lookup |
| `HomeApp/Intents/LogExpenseIntent.swift` | Action Button flow, category mapping, and App Shortcuts |
| `HomeApp.xcodeproj/project.pbxproj` | Targets, platform, concurrency, and build settings |
| `Docs/` | Original requirements and development plans |

`Docs/` describes an earlier iteration. Receipt flows, categories, authentication
notes, and feature status may differ from the code. Check implementation and flag
discrepancies rather than treating those documents as the current API contract.

## Change conventions

- Follow MVVM: views compose UI, view models manage feature state/actions, and
  `APIService` owns HTTP. Reuse shared components and error states.
- Most view models use `@Observable`; Insights uses `ObservableObject` and
  `@Published`. Follow the local pattern without migrating unrelated code.
- Use async/await and respect actor boundaries. The target enables approachable
  concurrency and default `MainActor` isolation; `APIService` is an actor.
- Match four-space indentation and existing `// MARK:` grouping.
- Preserve loading, empty, error, offline, and success states in affected flows.
- The project uses a filesystem-synchronized source group. New Swift files under
  `HomeApp/` normally do not need manual `project.pbxproj` entries.

## Behavior to check when changing a feature

- **Transactions:** date-range fetching is server-side; search, other filters,
  sorting, and pagination are client-side. Records display newest first in
  batches of 30.
- **Money:** transaction/create amounts use `Decimal`; report values currently
  use `Double`. Preserve currency and credit/debit semantics.
- **Categories:** raw values are API values. Check `CategoryEntity` and its mapping
  in the Intent when changing categories.
- **Expense entry:** check both the in-app form and App Intent. The Intent
  currently treats negative input as income, positive input as expense, sends the
  absolute amount, and uses CAD.
- **Location:** postal code is optional. Denied permission or unavailable location
  must not prevent saving.
- **Insights:** preserve housing/investment exclusions. Reports depend on backend
  aggregation; refreshing the client does not itself recompute reports.
- **Tab loading:** reuse successful loads for 60 seconds; pull-to-refresh bypasses
  that interval. Fetch transaction-based month details only after month selection,
  limited to that month's date range. Do not fetch a full year on tab appearance.

These describe current behavior to investigate when relevant, not a requirement
to preserve defects or fix unrelated issues.

## Backend compatibility

Before changing a contract, compare `APIService.swift` and the affected Swift
models with these backend sources:

- `../LambdaApps/AGENTS.md` for backend instructions.
- `../LambdaApps/service/api/handler.py` for registered routes.
- `../LambdaApps/service/api/routes/` for responses and status codes.
- `../LambdaApps/service/shared/models/` for validation, enums, and nullability.
- `../LambdaApps/service/api/auth.py` for authentication.

Current client resources are `/expense`, `/payment-schedule`, `/cash`, `/balance`,
`/report/trend`, and `/report/category-breakdown`. Check individual methods in
`APIService` before changing paths or response handling.

Preserve snake_case JSON keys, string IDs, optional fields, explicit Swift
`CodingKeys`, and enum spellings such as `Credit`, `Debit`, `CAD`, and `RMB`.
Expense lists decode directly as `[Transaction]`; creation returns `expense_id`.
Statuses vary by operation: balance creation accepts 201/202, and deletion expects
204. Do not standardize response handling without checking each route.

The shared encoder sends Toronto timestamps with offsets; transaction updates
use a separate ISO8601 encoder. Decoding supports UTC timestamps with or without
fractions or a trailing `Z`; date-range queries use UTC date-only values. Check
both encoders and backend UTC normalization when changing date handling.

Reports distinguish expense and earning categories: net expense is expense
debits minus credits; net earning is earning credits minus debits.

## Local setup and verification

The project targets iOS 26.2+ on iPhone and iPad, uses Swift language mode 5.0, and
was created with Xcode 26.2. It declares one app target, `HomeApp`, with no test
target or third-party package dependencies.

A full Xcode installation with the required iOS SDK is needed. Authentication
references `Secrets.apiBearerToken` in the git-ignored
`HomeApp/Config/Secrets.swift`. If missing, report that prerequisite; never invent
a working credential or copy secrets into tracked files.

From the repository root, inspect the selected toolchain and available schemes:

```sh
rtk xcode-select -p
rtk xcodebuild -list -project HomeApp.xcodeproj
```

After confirming the `HomeApp` scheme, use this simulator build command:

```sh
rtk xcodebuild -project HomeApp.xcodeproj -scheme HomeApp -configuration Debug -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/HomeApp-DerivedData CODE_SIGNING_ALLOWED=NO build
```

If Command Line Tools is selected, use the installed Xcode for individual commands
without changing the machine's global selection:

```sh
rtk env DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcrun xcodebuild -list -project HomeApp.xcodeproj
```

Run the offline Insights model/view-model regression checks on macOS:

```sh
rtk bash Tests/Insights/run.sh
rtk bash Tests/TabLoading/run.sh
```

These compile the real models and view model with a test-only network boundary.
They do not read local credentials or contact the API.

For code changes, build and verify the affected flow with local fixtures/mocks
when available. Check relevant error/offline paths, currency/date handling, and
form/Intent parity. There is no Xcode test target currently; report standalone
checks, simulator checks, and manual checks separately. For documentation changes, review facts, paths,
and whitespace; no app build is needed.

Finish with `rtk git diff --check` and `rtk git status --short`. For new untracked
documents, also inspect their contents because ordinary git diff omits them.

Follow the user's global working agreements, including `rtk` for shell commands,
`uv` for Python, and no commits or pushes unless requested. Ask before external
requests: launching the app or invoking shortcuts can contact the live API.
Never use cash resets, backend batch handlers, or reaggregation scripts as routine
verification; these can mutate financial records.
