# Expense Logger - Requirements

## Overview

The Expense Logger provides quick expense/income entry capabilities through two entry points:
1. **Action Button Snippet** - For iPhone 15 Pro/16 users, triggered via the hardware Action Button
2. **Floating Action Button** - In-app button on the Transactions view for all users

The view is a single, compact form with all fields visible for fast entry.

## User Stories

### US-3.1: Quick Log via Action Button
**As a** family member with iPhone 15 Pro or newer  
**I want to** log an expense using the Action Button  
**So that** I can record expenses instantly without opening the app

**Acceptance Criteria:**
- Action Button triggers expense logger snippet
- Snippet appears as system overlay (without fully opening app)
- All fields visible in one view
- Submit logs the expense via API
- Success confirmation shown (checkmark animation)
- Dismisses automatically after success

### US-3.2: Quick Log via Floating Button
**As a** family member  
**I want to** log an expense from within the app  
**So that** I can quickly add expenses while viewing transactions

**Acceptance Criteria:**
- Floating button visible on Transactions view
- Tapping opens expense logger as sheet/modal
- Same interface as Action Button snippet
- Can be dismissed by swipe down
- Success feedback matches Action Button flow

### US-3.3: Enter Amount
**As a** family member  
**I want to** enter the transaction amount  
**So that** the correct value is recorded

**Acceptance Criteria:**
- Prominent amount input field
- Currency symbol (CAD $) shown
- Numeric keypad for input
- Decimal support (2 places max)
- Amount must be greater than 0 to submit

### US-3.4: Select Transaction Type
**As a** family member  
**I want to** choose between Credit and Debit  
**So that** I can log both income and expenses

**Acceptance Criteria:**
- Small toggle switch for Credit/Debit
- **Debit selected by default**
- Toggle is compact and easy to tap
- Visual distinction between selected states

### US-3.5: Select Category (Roller Picker)
**As a** family member  
**I want to** select a category using a roller picker  
**So that** I can quickly scroll to my desired category

**Acceptance Criteria:**
- Display all 8 categories in a wheel/roller picker
- Each category shows icon and label
- Default selection: First category (Groceries)
- Smooth scrolling with haptic feedback at each stop

**Categories:**
| Category | Icon | Color |
|----------|------|-------|
| Groceries | cart.fill | Green |
| EatOut | fork.knife | Orange |
| Transportation | car.fill | Blue |
| Mortgage | house.fill | Purple |
| Utilities | bolt.fill | Yellow |
| Shopping | bag.fill | Pink |
| Gas | fuelpump.fill | Red |
| Insurance | shield.fill | Teal |

### US-3.6: Add Optional Details
**As a** family member  
**I want to** optionally add merchant and description  
**So that** I can add context to the transaction

**Acceptance Criteria:**
- Two text fields:
  - **Merchant**: Placeholder "Merchant name (optional)"
  - **Note**: Placeholder "Note (optional)"
- Both fields are optional (can be empty)
- Character limits:
  - Merchant: 100 characters
  - Note: 200 characters
- Fields are compact to fit in single view

### US-3.7: Submit Transaction
**As a** family member  
**I want to** submit my transaction  
**So that** it is saved to our records

**Acceptance Criteria:**
- Submit button clearly visible
- Button disabled until amount > 0
- Button label changes based on type: "Log Expense" or "Log Income"
- API call made on submit
- Loading indicator during submission
- Success: checkmark animation + haptic
- Failure: error message with retry option
- Auto-dismiss 1.5 seconds after success

### US-3.8: Success Confirmation
**As a** family member  
**I want to** see a quick confirmation after logging  
**So that** I know the transaction was recorded

**Acceptance Criteria:**
- Animated checkmark on success
- Haptic feedback (success pattern)
- Brief message showing what was logged
- Auto-dismiss after confirmation

## UI/UX Requirements

### Layout - Single View

```
┌─────────────────────────────────┐
│          Log Expense            │  ← Title
│              ─                  │  ← Drag indicator (if sheet)
├─────────────────────────────────┤
│                                 │
│         $ 0.00                  │  ← Amount display (large)
│                                 │
│     ┌────────────────────┐     │
│     │ Debit ● ○ Credit   │     │  ← Type toggle (small)
│     └────────────────────┘     │
│                                 │
├─────────────────────────────────┤
│  Category                       │
│  ┌─────────────────────────┐   │
│  │      Transportation      │   │  ← Previous (faded)
│  ├─────────────────────────┤   │
│  │  🛒   Groceries         │   │  ← Selected (highlighted)
│  ├─────────────────────────┤   │
│  │      Eat Out            │   │  ← Next (faded)
│  └─────────────────────────┘   │
│                                 │
├─────────────────────────────────┤
│  ┌─────────────────────────┐   │
│  │ Merchant (optional)     │   │  ← Merchant field
│  └─────────────────────────┘   │
│  ┌─────────────────────────┐   │
│  │ Note (optional)         │   │  ← Note field
│  └─────────────────────────┘   │
├─────────────────────────────────┤
│  ┌─────┐ ┌─────┐ ┌─────┐       │
│  │  1  │ │  2  │ │  3  │       │
│  ├─────┤ ├─────┤ ├─────┤       │  ← Numeric keypad
│  │  4  │ │  5  │ │  6  │       │
│  ├─────┤ ├─────┤ ├─────┤       │
│  │  7  │ │  8  │ │  9  │       │
│  ├─────┤ ├─────┤ ├─────┤       │
│  │  .  │ │  0  │ │  ⌫  │       │
│  └─────┘ └─────┘ └─────┘       │
│                                 │
│  ┌─────────────────────────┐   │
│  │      Log Expense        │   │  ← Submit button
│  └─────────────────────────┘   │
│                                 │
└─────────────────────────────────┘
```

### Layout - Success State

```
┌─────────────────────────────────┐
│                                 │
│                                 │
│            ✓                    │  ← Animated checkmark
│                                 │
│    Groceries -$25.00            │  ← What was logged
│        logged!                  │
│                                 │
│                                 │
└─────────────────────────────────┘
```

### Visual Design

| Element | Specification |
|---------|---------------|
| **Amount Display** | 40pt, semibold, monospaced digits |
| **Currency Symbol** | 20pt, secondary color |
| **Type Toggle** | Compact segmented or custom toggle |
| **Category Roller** | Native Picker with .wheel style, ~100pt height |
| **Text Fields** | Compact, 40pt height each |
| **Keypad Buttons** | 56x48pt, system background |
| **Submit Button** | Full width, accent color, 48pt height |
| **Success Checkmark** | Green, animated draw |

### Animations & Haptics

| Action | Animation/Haptic |
|--------|------------------|
| **Category Scroll** | `.selection` haptic at each stop |
| **Keypad Tap** | `.impact(weight: .light)` |
| **Toggle Switch** | `.selection` |
| **Submit** | `.impact(weight: .medium)` |
| **Success** | `.success` + checkmark draw animation |

## API Requirements

### POST /expense

**Request:**
```http
POST /expense
Content-Type: application/json

{
  "amount": 25.99,
  "category": "Groceries",
  "transaction_type": "Debit",
  "merchant": "Costco",
  "description": "Weekly shopping"
}
```

**Notes:**
- `merchant` and `description` are optional (can be null or omitted)
- `transaction_type` is "Credit" or "Debit"

**Response:**
```json
{
  "message": "Expense created successfully",
  "expense_id": "abc123"
}
```

### Validation Rules

| Field | Rule |
|-------|------|
| **amount** | Required, > 0, ≤ 999,999.99 |
| **category** | Required, must be valid enum |
| **transaction_type** | Required, "Credit" or "Debit" |
| **merchant** | Optional, max 100 chars |
| **description** | Optional, max 200 chars |

## Technical Requirements

### App Intents Implementation

For Action Button support, we use a **parameter-based AppIntent** that leverages the system's built-in prompts for data collection:

```swift
import AppIntents

struct LogExpenseIntent: AppIntent {
    static var title: LocalizedStringResource = "Log Expense"
    static var description = IntentDescription("Quickly log a new expense with category, amount, and type")
    static var openAppWhenRun: Bool = false
    
    @Parameter(title: "Category", requestValueDialog: "Which category?")
    var category: CategoryEntity
    
    @Parameter(title: "Amount", requestValueDialog: "What's the amount?")
    var amount: Double
    
    @Parameter(title: "Type", default: .debit)
    var transactionType: TransactionTypeEntity
    
    func perform() async throws -> some IntentResult & ShowsSnippetView & ProvidesDialog {
        // Create and save expense via API
        // ...
        return .result(
            dialog: "Logged Groceries -$25.00",
            view: ExpenseLoggerConfirmation(message: "Groceries -$25.00")
        )
    }
}
```

**Flow:**
1. User triggers Action Button → System prompts for **Category** selection
2. System prompts for **Amount** input
3. System uses default **Debit** type (or prompts if needed)
4. Intent performs API call and shows **ExpenseLoggerConfirmation** view

### Error Handling

| Error | User Message | Action |
|-------|--------------|--------|
| Network unavailable | "No connection. Try again." | Show retry button |
| API error | "Failed to save. Try again." | Show retry button |
| Invalid amount | "Enter a valid amount" | Keep on form |
| Server timeout | "Taking too long. Try again." | Show retry button |

## Dependencies

- **iOS Frameworks**: SwiftUI, AppIntents
- **Updates**: Transactions list (on success, list should refresh)
- **Uses**: APIService for expense creation

## Action Button Configuration

Users must configure their Action Button to use this intent:
1. Settings → Action Button
2. Select "Shortcut"
3. Choose "Log Expense" from HomeApp
