# Transactions View - Requirements

## Overview

The Transactions View is the main screen of the app, displaying a chronological list of all family transactions (both Credit and Debit) with filtering, searching, and quick access to logging new expenses. This view uses a bottom navigation bar for app-wide navigation.

## User Stories

### US-1.1: View Transaction List
**As a** family member  
**I want to** see a list of all transactions  
**So that** I can review our family's spending history

**Acceptance Criteria:**
- Display transactions in reverse chronological order (newest first)
- Each transaction row shows:
  - Category icon (colored)
  - Category name
  - Merchant name (if available) OR description (if available) OR empty
  - Date with time (e.g., "Jan 30, 10:30 AM")
  - Amount
  - Receipt indicator (paperclip icon if receipt exists)
- Credit amounts displayed in green with "+" prefix
- Debit amounts displayed in red with "-" prefix
- Amounts formatted as CAD currency (e.g., "$15.49")
- Tapping row navigates to Transaction Detail

### US-1.2: Filter by Time Range
**As a** family member  
**I want to** filter transactions by time period  
**So that** I can focus on recent or historical spending

**Acceptance Criteria:**
- Filter options: Last 1 month, 3 months, 6 months, 1 year
- Default filter: Last 1 month
- Filter selection persists during session
- Visual indicator shows active filter

### US-1.3: Advanced Filters
**As a** family member  
**I want to** filter transactions by various criteria  
**So that** I can find specific types of transactions

**Acceptance Criteria:**
- Filter button at top opens filter sheet
- Filter options:
  - **Category**: Single-select from all categories (one at a time)
  - **Has Receipt**: Yes / No / All
  - **Type**: Credit / Debit / All
  - **Amount Range**: Min and Max amount inputs
- Active filters shown as chips/badges
- "Clear All" option to reset filters
- Filter count badge on filter button when filters active

### US-1.4: Search Transactions
**As a** family member  
**I want to** search transactions  
**So that** I can quickly find specific expenses

**Acceptance Criteria:**
- Search bar at top of screen (below navigation title)
- Searches across: amount, category, merchant, description
- Real-time filtering as user types
- Clear button to reset search
- "No results" state when search returns empty

### US-1.5: Navigate to Transaction Detail
**As a** family member  
**I want to** tap on a transaction  
**So that** I can view full details, edit, or download receipt

**Acceptance Criteria:**
- Tapping transaction row navigates to Transaction Detail view
- Transaction data passed to detail view (no separate API call needed)
- Navigation uses standard iOS push animation
- Back navigation returns to list with preserved filter/search state

### US-1.6: Receipt Indicator
**As a** family member  
**I want to** see which transactions have receipts  
**So that** I know I can download them in the detail view

**Acceptance Criteria:**
- Small paperclip icon shown on transactions with `receipt_id` (not null)
- Icon positioned consistently (trailing side of row)
- No icon shown when `receipt_id` is null
- Tapping row navigates to detail where receipt can be downloaded

### US-1.7: Quick Expense Logging
**As a** family member  
**I want to** quickly log an expense from the transactions screen  
**So that** I don't have to navigate elsewhere

**Acceptance Criteria:**
- Floating action button (FAB) visible on screen
- FAB positioned at bottom-right, above tab bar
- Tapping FAB opens expense logger sheet
- FAB uses consistent app accent color

### US-1.8: Pull to Refresh
**As a** family member  
**I want to** pull down to refresh the list  
**So that** I can see the latest transactions

**Acceptance Criteria:**
- Standard iOS pull-to-refresh gesture
- Loading indicator during refresh
- List updates with new data
- Error handling if refresh fails

### US-1.9: Client-Side Pagination
**As a** family member  
**I want to** scroll to see more transactions  
**So that** I can view my complete history

**Acceptance Criteria:**
- Fetch all transactions from API on load
- Display first 30 transactions initially
- When scrolling near bottom, show next batch of 30
- Continue until all transactions displayed

### US-1.10: Offline State
**As a** family member  
**I want to** know when the app is offline  
**So that** I understand why features aren't working

**Acceptance Criteria:**
- Detect network connectivity status
- Show offline banner/indicator when no connection
- Disable FAB when offline
- Show message: "You're offline. Connect to use the app."

### US-1.11: Bottom Navigation
**As a** family member  
**I want to** navigate between app sections  
**So that** I can access different features

**Acceptance Criteria:**
- Bottom tab bar with 4 items
- Tab 1: Transactions (current, active)
- Tab 2: Placeholder (future feature)
- Tab 3: Placeholder (future feature)
- Tab 4: Placeholder (future feature)
- Active tab clearly highlighted

## UI/UX Requirements

### Layout

```
┌─────────────────────────────────┐
│  Transactions              🔽   │  ← Title + Filter button
├─────────────────────────────────┤
│  🔍 Search                      │  ← Search bar
├─────────────────────────────────┤
│  Last 1 month ▼                 │  ← Time range selector
├─────────────────────────────────┤
│  [Category] [Has Receipt] [+1]  │  ← Active filter chips (if any)
├─────────────────────────────────┤
│                                 │
│  ┌─────────────────────────┐   │
│  │ 🛒 Groceries    -$85.50 │   │
│  │    Costco               │   │
│  │    Jan 30, 10:30 AM  📎 │   │  ← Receipt indicator
│  └─────────────────────────┘   │
│                                 │
│  ┌─────────────────────────┐   │
│  │ 🍽️ Eat Out      -$42.00 │   │
│  │    Restaurant ABC       │   │
│  │    Jan 29, 7:15 PM      │   │  ← No receipt
│  └─────────────────────────┘   │
│                                 │
│  ┌─────────────────────────┐   │
│  │ 💰 Income      +$500.00 │   │  ← Credit transaction
│  │                         │   │
│  │    Jan 28, 9:00 AM      │   │
│  └─────────────────────────┘   │
│                                 │
│                          ⊕     │  ← Floating Action Button
├─────────────────────────────────┤
│  📋      ○       ○       ○     │  ← Bottom Tab Bar (4 tabs)
│ Trans  Future  Future  Future  │
└─────────────────────────────────┘
```

### Transaction Row Layout

```
┌─────────────────────────────────────────┐
│  🛒  Groceries              -$85.50     │
│      Costco                             │
│      Jan 30, 10:30 AM               📎  │
└─────────────────────────────────────────┘
  ↑      ↑        ↑             ↑      ↑
Icon  Category  Merchant      Amount  Receipt
              (optional)      + Date  Indicator
```

### Filter Sheet Layout

```
┌─────────────────────────────────┐
│  Filters                Clear   │
│              ─                  │
├─────────────────────────────────┤
│                                 │
│  Category (select one)          │
│  ○ All                          │
│  ○ Groceries                    │
│  ○ Eat Out                      │
│  ○ Transportation               │
│  ○ Mortgage                     │
│  ○ Utilities                    │
│  ○ Shopping                     │
│  ○ Gas                          │
│  ○ Insurance                    │
│                                 │
│  Transaction Type               │
│  ○ All  ○ Credit  ○ Debit      │
│                                 │
│  Has Receipt                    │
│  ○ All  ○ Yes  ○ No            │
│                                 │
│  Amount Range                   │
│  Min: [$______]  Max: [$______]│
│                                 │
│  ┌─────────────────────────┐   │
│  │      Apply Filters      │   │
│  └─────────────────────────┘   │
│                                 │
└─────────────────────────────────┘
```

### Visual Design

| Element | Specification |
|---------|---------------|
| **Background** | System background (adaptive light/dark) |
| **Transaction Row** | Rounded rectangle, subtle shadow, full-width tap target |
| **Category Icons** | SF Symbols, colored by category |
| **Category Name** | Primary text, medium weight |
| **Merchant/Desc** | Secondary text color |
| **Amount (Credit)** | System green, semibold |
| **Amount (Debit)** | System red, semibold |
| **Date Format** | "MMM dd, h:mm a" (e.g., "Jan 30, 10:30 AM") |
| **Receipt Indicator** | SF Symbol `paperclip`, small, secondary color |
| **FAB** | 56pt circle, accent color, shadow |
| **Search Bar** | iOS native search bar style |
| **Tab Bar** | iOS native tab bar |

### Category Icons (SF Symbols)

| Category | SF Symbol | Color |
|----------|-----------|-------|
| Groceries | `cart.fill` | Green |
| EatOut | `fork.knife` | Orange |
| Transportation | `car.fill` | Blue |
| Mortgage | `house.fill` | Purple |
| Utilities | `bolt.fill` | Yellow |
| Shopping | `bag.fill` | Pink |
| Gas | `fuelpump.fill` | Red |
| Insurance | `shield.fill` | Teal |

### Empty States

**No Transactions:**
- Illustration or SF Symbol (`tray.fill`)
- Message: "No transactions yet"
- Subtitle: "Tap + to log your first expense"

**No Search/Filter Results:**
- SF Symbol (`magnifyingglass`)
- Message: "No results found"
- Subtitle: "Try different filters or search term"

**Error State:**
- SF Symbol (`exclamationmark.triangle`)
- Message: "Unable to load transactions"
- Retry button

**Offline State:**
- SF Symbol (`wifi.slash`)
- Message: "You're offline"
- Subtitle: "Connect to the internet to use the app"
- Disable FAB

## API Requirements

### GET /expenses

**Request:**
```http
GET /expenses
```

**Response:**
```json
{
  "expenses": [
    {
      "id": "abc123",
      "amount": 85.50,
      "category": "Groceries",
      "transaction_type": "Debit",
      "created_at": "2026-01-30T10:30:00Z",
      "merchant": "Costco",
      "description": "Weekly groceries",
      "receipt_id": "receipt_xyz789"
    },
    {
      "id": "def456",
      "amount": 42.00,
      "category": "EatOut",
      "transaction_type": "Debit",
      "created_at": "2026-01-29T19:15:00Z",
      "merchant": null,
      "description": null,
      "receipt_id": null
    }
  ]
}
```

**Note:** 
- `receipt_id` is `null` when no receipt exists
- `merchant` and `description` are optional (can be null)
- All filtering is done client-side after fetching all data

## Technical Requirements

### Performance
- Initial load: < 2 seconds
- Search/filter: < 100ms (client-side)
- Show first 30 records, load 30 more on scroll

### Network Handling
- Detect connectivity using `NWPathMonitor`
- Show offline state when no connection
- Disable FAB when offline
- Re-fetch when connection restored

### State Management
- Preserve filter/search state during navigation
- Pass transaction data to detail view (no separate fetch)

## Dependencies

- **Views**: Root view with tab bar
- **Navigates to**: Transaction Detail View (passes Transaction object)
- **Data**: TransactionsViewModel, APIService
