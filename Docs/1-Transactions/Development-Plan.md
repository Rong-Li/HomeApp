# Transactions View - Development Plan

## Overview

Implementation plan for the Transactions View, broken into phases for incremental development.

## Phase 1: Foundation & Models

### 1.1 Create Data Models

**Files to create:**
- `Models/Transaction.swift` - Transaction model with id, amount, category, transactionType, createdAt, merchant, description, receiptId; computed properties for formattedAmount, formattedDateTime, hasReceipt
- `Models/Category.swift` - Enum with all 8 categories, displayName, icon (SF Symbols), color
- `Models/TransactionType.swift` - Credit/Debit enum
- `Models/TimeRange.swift` - One month, 3 months, 6 months, 1 year with startDate
- `Models/TransactionFilters.swift` - selectedCategory (single), transactionType, hasReceipt, minAmount, maxAmount

### 1.2 Create API Service

**Files to create:**
- `Services/APIService.swift` - fetchTransactions() to GET /expenses
- `Services/APIError.swift` - Error types
- `Services/NetworkMonitor.swift` - NWPathMonitor for connectivity

---

## Phase 2: UI Components

### 2.1 Transaction Row
- `Views/Transactions/TransactionRowView.swift` - Category icon, name, merchant/subtitle, date with time, amount (green/red), paperclip if hasReceipt

### 2.2 Filter & Time Components
- `Views/Transactions/TimeRangePickerView.swift` - Menu with time range options
- `Views/Transactions/TransactionFilterSheet.swift` - Form with category (single-select), type, has_receipt, amount range
- `Views/Transactions/ActiveFilterChipsView.swift` - Horizontal chips for active filters + Clear button

### 2.3 Shared Components
- `Views/Components/FloatingActionButton.swift` - Circular FAB, disabled when offline
- `Views/Components/StateViews.swift` - EmptyStateView, OfflineStateView, ErrorStateView

---

## Phase 3: ViewModel & State Management

### 3.1 TransactionsViewModel
- Fetch all transactions from API
- Client-side filtering: time range, category, type, has_receipt, amount range, search
- Client-side pagination: displayedCount starts at 30, loadMore() adds 30
- filteredTransactions and displayedTransactions computed properties

---

## Phase 4: Main View Assembly

### 4.1 MainTabView
- TabView with 4 tabs: Transactions, Insights (placeholder), Investments (placeholder), Settings (placeholder)

### 4.2 TransactionsView
- NavigationStack with searchable, filter toolbar, refreshable
- Time range picker and active filter chips at top
- List with NavigationLink to TransactionDetailView
- Load more trigger at bottom when canLoadMore
- Offline state replaces main content when disconnected
- FAB opens ExpenseLoggerView sheet
- Filter sheet for advanced filters

---

## Implementation Checklist

### Phase 1: Foundation
- [ ] Transaction.swift
- [ ] Category.swift
- [ ] TransactionType.swift
- [ ] TimeRange.swift
- [ ] TransactionFilters.swift
- [ ] APIService.fetchTransactions()
- [ ] APIError.swift
- [ ] NetworkMonitor.swift

### Phase 2: UI Components
- [ ] TransactionRowView
- [ ] TimeRangePickerView
- [ ] TransactionFilterSheet (single-select category)
- [ ] ActiveFilterChipsView
- [ ] FloatingActionButton
- [ ] StateViews (empty, offline, error)

### Phase 3: State Management
- [ ] TransactionsViewModel
- [ ] Client-side filtering logic
- [ ] Client-side pagination

### Phase 4: Main Views
- [ ] MainTabView
- [ ] TransactionsView
- [ ] Integration and wiring

---

## Testing Plan

- Unit tests: Model encoding/decoding, TimeRange dates, filter logic, search logic
- Manual: Screen sizes, light/dark mode, network changes, tab navigation
