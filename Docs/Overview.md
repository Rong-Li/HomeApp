# HomeApp - Family Expense Tracker

## Project Overview

HomeApp is an iOS application designed to help families log, track, and manage their expenses. The app communicates with a backend Lambda API that persists data to MongoDB.

## Technical Stack

| Component | Technology |
|-----------|------------|
| **Platform** | iOS 26+ |
| **UI Framework** | SwiftUI |
| **Architecture** | MVVM |
| **Networking** | Swift Concurrency (async/await) + URLSession |
| **Action Button** | App Intents Framework |
| **Target Devices** | iPhone 16 series (minimum) |

## API Configuration

| Setting | Value |
|---------|-------|
| **Base URL** | `https://tzy15xk1hg.execute-api.ca-central-1.amazonaws.com` |
| **Authentication** | API Key (to be implemented) |
| **Currency** | CAD (display) |

## Data Models

### Transaction (Expense)

```swift
struct Transaction: Identifiable, Codable {
    let id: String
    var amount: Decimal
    var category: Category
    var transactionType: TransactionType
    var createdAt: Date
    var merchant: String?        // Optional
    var description: String?     // Optional
    var receiptId: String?       // If not null, receipt exists
}
```

### Category

```swift
enum Category: String, Codable, CaseIterable {
    case groceries = "Groceries"
    case eatOut = "EatOut"
    case transportation = "Transportation"
    case mortgage = "Mortgage"
    case utilities = "Utilities"
    case shopping = "Shopping"
    case gas = "Gas"
    case insurance = "Insurance"
}
```

### TransactionType

```swift
enum TransactionType: String, Codable {
    case credit = "Credit"   // Income
    case debit = "Debit"     // Expense
}
```

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/expenses` | List all transactions |
| POST | `/expense` | Create new transaction |
| PUT | `/expense/{id}` | Update transaction |
| DELETE | `/expense/{id}` | Delete transaction |
| POST | `/expense/{id}/receipt/upload-url` | Get S3 pre-signed PUT URL |
| POST | `/expense/{id}/receipt/confirm` | Confirm receipt upload |
| GET | `/expense/{id}/receipt/view-url` | Get S3 pre-signed GET URL |

## App Navigation

Bottom tab bar with 4 tabs:
1. **Transactions** - Main transaction list (implemented)
2. **Insights** - Coming soon (placeholder)
3. **Investments** - Coming soon (placeholder)
4. **Settings** - Coming soon (placeholder)

## Current Iteration Scope

| # | Feature | Status |
|---|---------|--------|
| 1 | Transactions List | 📋 Planned |
| 2 | Transaction Detail | 📋 Planned |
| 3 | Expense Logger (Action Button + FAB) | 📋 Planned |

## Future Iterations

| # | Feature | Description |
|---|---------|-------------|
| 4 | Optimistic Updates | Instant UI feedback before API response |
| 5 | FinanceKit Integration | Import Apple Pay transactions |
| 6 | Investments | Family investment tracking |
| 7 | Insights | Aggregated analytics dashboard |
| 8 | Authentication | API key / Apple Sign-In |

## Project Structure (Planned)

```
HomeApp/
├── App/
│   └── HomeAppApp.swift
├── Models/
│   ├── Transaction.swift
│   ├── Category.swift
│   ├── TransactionType.swift
│   ├── TimeRange.swift
│   ├── TransactionFilters.swift
│   └── ExpenseCreate.swift
├── Views/
│   ├── MainTabView.swift
│   ├── Transactions/
│   │   ├── TransactionsView.swift
│   │   ├── TransactionRowView.swift
│   │   ├── TimeRangePickerView.swift
│   │   ├── TransactionFilterSheet.swift
│   │   └── ActiveFilterChipsView.swift
│   ├── TransactionDetail/
│   │   ├── TransactionDetailView.swift
│   │   ├── TransactionEditForm.swift
│   │   ├── ReceiptSectionView.swift
│   │   └── ReceiptViewerView.swift
│   ├── ExpenseLogger/
│   │   ├── ExpenseLoggerView.swift
│   │   ├── AmountDisplayView.swift
│   │   ├── TransactionTypeToggle.swift
│   │   ├── CategoryPickerView.swift
│   │   ├── NumericKeypadView.swift
│   │   ├── SuccessView.swift
│   │   └── ExpenseLoggerSnippetView.swift
│   └── Components/
│       ├── FloatingActionButton.swift
│       └── StateViews.swift
├── ViewModels/
│   ├── TransactionsViewModel.swift
│   ├── TransactionDetailViewModel.swift
│   └── ExpenseLoggerViewModel.swift
├── Services/
│   ├── APIService.swift
│   ├── APIError.swift
│   └── NetworkMonitor.swift
├── Intents/
│   └── LogExpenseIntent.swift
└── Resources/
    └── Assets.xcassets/
```

## Key Features Summary

### Transactions View
- List of all transactions (newest first)
- Time range filter: 1M, 3M, 6M, 1Y
- Advanced filters: category (single-select), type, has_receipt, amount range
- Search across amount, category, merchant, description
- Date/time display: "Jan 30, 10:30 AM"
- Paperclip icon for transactions with receipts
- Client-side pagination: show 30, load more on scroll
- Floating action button for quick logging
- Bottom tab bar with 4 tabs (3 placeholders for future)
- Offline state handling

### Transaction Detail View
- View all transaction details (data from list, no extra API call)
- Edit all fields via `PUT /expense/{id}`
- Receipt management via S3 pre-signed URLs:
  - Upload: Get PUT URL → Upload to S3 → Confirm
  - View: Get GET URL → Display
- Delete transaction via `DELETE /expense/{id}`

### Expense Logger
- Single compact view with all fields
- Amount input with numeric keypad
- Credit/Debit toggle (Debit default)
- Category roller/wheel picker
- Optional merchant and note fields
- Action Button integration (App Intents)
- Floating button in Transactions view
- Success animation with haptic feedback

## Design Principles

1. **Modern iOS Aesthetics**: Native iOS 26 components, SF Symbols, system colors
2. **Responsive Layout**: Optimized for iPhone 16 screen sizes
3. **Haptic Feedback**: Confirmation feedback for actions throughout
4. **Single-View Logging**: All expense fields in one compact view
5. **Offline Awareness**: Clear messaging when offline, features disabled

## Documentation Structure

Each feature has its own documentation folder:

- `/Docs/1-Transactions/` - Transaction list view
- `/Docs/2-TransactionDetail/` - Transaction detail/edit view
- `/Docs/3-ExpenseLogger/` - Quick expense logging (Action Button + FAB)
