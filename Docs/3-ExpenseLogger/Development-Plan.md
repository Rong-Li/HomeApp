# Expense Logger - Development Plan

## Overview

Implementation plan for the Expense Logger—single-view form for both Action Button snippet and in-app sheet.

## Phase 1: Core Components

### 1.1 ViewModel
- `ViewModels/ExpenseLoggerViewModel.swift` - amountString, transactionType, selectedCategory, merchant, note; appendDigit, deleteLastDigit, submit; validation and success state

### 1.2 Create Model
- `Models/ExpenseCreate.swift` - Encodable for POST /expense

---

## Phase 2: UI Components

### 2.1 Form Elements
- `Views/ExpenseLogger/AmountDisplayView.swift` - Large amount display with $ prefix
- `Views/ExpenseLogger/TransactionTypeToggle.swift` - Segmented Debit/Credit picker (Debit default)
- `Views/ExpenseLogger/CategoryPickerView.swift` - Wheel picker with all categories
- `Views/ExpenseLogger/NumericKeypadView.swift` - Custom keypad (0-9, ., delete)
- `Views/ExpenseLogger/SuccessView.swift` - Animated checkmark + message

---

## Phase 3: Main View

### 3.1 Expense Logger Sheet
- `Views/ExpenseLogger/ExpenseLoggerView.swift` - NavigationStack, form or success view, Cancel in toolbar, presentationDetents large, onSuccess callback to refresh list

### 3.2 Form Layout
- Amount → Type toggle → Category picker → Merchant field → Note field → Keypad → Submit button

---

## Phase 4: Action Button Integration

### 4.1 App Intent (Parameter-Based)
- `Intents/LogExpenseIntent.swift` - LogExpenseIntent with **@Parameter** properties for category, amount, type
- System handles prompts for each parameter via `requestValueDialog`
- Returns `ShowsSnippetView & ProvidesDialog` with confirmation

### 4.2 App Shortcuts
- HomeAppShortcuts - Register "Log Expense" shortcut for Action Button

### 4.3 Confirmation View
- `ExpenseLoggerConfirmation` - Success confirmation view shown after expense is logged via system prompts

---

## Phase 5: API Integration

- Add createExpense to APIService (POST /expense)
- Handle response and errors

---

## Implementation Checklist

### Phase 1: Core
- [ ] ExpenseLoggerViewModel
- [ ] ExpenseCreate model

### Phase 2: UI Components
- [ ] AmountDisplayView
- [ ] TransactionTypeToggle
- [ ] CategoryPickerView (wheel)
- [ ] NumericKeypadView
- [ ] SuccessView

### Phase 3: Main View
- [ ] ExpenseLoggerView
- [ ] Sheet presentation

### Phase 4: Action Button
- [ ] LogExpenseIntent
- [ ] HomeAppShortcuts
- [ ] ExpenseLoggerConfirmation

### Phase 5: API
- [ ] createExpense in APIService
