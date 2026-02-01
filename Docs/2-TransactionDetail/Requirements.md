# Transaction Detail View - Requirements

## Overview

The Transaction Detail View displays the complete details of a single transaction and allows users to view, edit, upload/download receipts, and delete the transaction. Transaction data is passed from the Transactions list (no separate GET call needed).

## User Stories

### US-2.1: View Transaction Details
**As a** family member  
**I want to** see all details of a transaction  
**So that** I can review the complete information

**Acceptance Criteria:**
- Display all transaction fields:
  - Amount (formatted as CAD)
  - Category (with icon)
  - Transaction Type (Credit/Debit)
  - Date and time
  - Merchant (if available)
  - Description (if available)
- Clear visual hierarchy with labels
- Back navigation to Transactions list
- Data received from Transactions list (no API call)

### US-2.2: Edit Transaction
**As a** family member  
**I want to** modify transaction details  
**So that** I can correct errors or add information

**Acceptance Criteria:**
- All fields are editable:
  - Amount: Numeric keyboard input
  - Category: Picker selection
  - Transaction Type: Segmented control (Credit/Debit)
  - Date: Date picker
  - Merchant: Text field
  - Description: Multi-line text field
- Edit mode toggle (Edit/Done button)
- Save confirmation before leaving if changes exist
- Cancel option to discard changes
- Validation: Amount must be positive
- API: `PUT /expense/{id}`

### US-2.3: Upload Receipt
**As a** family member  
**I want to** attach a receipt to a transaction  
**So that** I have proof of purchase for records

**Acceptance Criteria:**
- "Add Receipt" button visible when no receipt exists
- Options to upload:
  - Take photo (camera)
  - Choose from Photos library
  - Choose from Files (for PDFs)
- Supported formats: JPEG, PNG, PDF
- Upload flow (S3 pre-signed URL):
  1. App requests pre-signed PUT URL from backend
  2. App uploads file directly to S3
  3. App notifies backend of successful upload with filename
- Upload progress indicator
- Success/failure feedback

### US-2.4: Download/View Receipt
**As a** family member  
**I want to** view and download an attached receipt  
**So that** I can access the receipt when needed

**Acceptance Criteria:**
- "View Receipt" button visible when receipt exists (`receipt_id` not null)
- Download flow (S3 pre-signed URL):
  1. App requests pre-signed GET URL from backend
  2. App displays image/PDF using that URL
- Full-screen viewing for images
- PDF viewer for PDF files
- Share button to export/save receipt
- Option to replace existing receipt

### US-2.5: Delete Transaction
**As a** family member  
**I want to** delete a transaction from the detail view  
**So that** I can remove incorrect entries

**Acceptance Criteria:**
- Swipe-to-delete OR delete button in view
- Confirmation alert before deletion
- API: `DELETE /expense/{id}`
- After deletion, navigate back to Transactions list
- Haptic feedback on success

## UI/UX Requirements

### Layout - View Mode

```
┌─────────────────────────────────┐
│  ←  Transaction         Edit    │  ← Navigation bar
├─────────────────────────────────┤
│                                 │
│     ┌─────────────────────┐     │
│     │     🛒              │     │  ← Category icon (large)
│     │   -$85.50           │     │  ← Amount (prominent)
│     │    Groceries        │     │  ← Category name
│     └─────────────────────┘     │
│                                 │
├─────────────────────────────────┤
│  DETAILS                        │  ← Section header
│  ─────────────────────────────  │
│  Type          Debit            │
│  ─────────────────────────────  │
│  Date          Jan 30, 2026     │
│                10:30 AM         │
│  ─────────────────────────────  │
│  Merchant      Costco           │
│  ─────────────────────────────  │
│  Description   Weekly groceries │
│                                 │
├─────────────────────────────────┤
│  RECEIPT                        │  ← Section header
│  ─────────────────────────────  │
│                                 │
│   ┌─────────────────────────┐  │
│   │  📎 View Receipt        │  │  ← If receipt exists
│   └─────────────────────────┘  │
│        OR                       │
│   ┌─────────────────────────┐  │
│   │  📷 Add Receipt         │  │  ← If no receipt
│   └─────────────────────────┘  │
│                                 │
├─────────────────────────────────┤
│                                 │
│   ┌─────────────────────────┐  │
│   │   🗑️ Delete Transaction  │  │  ← Destructive action
│   └─────────────────────────┘  │
│                                 │
└─────────────────────────────────┘
```

### Layout - Edit Mode

```
┌─────────────────────────────────┐
│  Cancel  Transaction     Done   │  ← Edit mode navigation
├─────────────────────────────────┤
│                                 │
│  Amount                         │
│  ┌─────────────────────────┐   │
│  │ $ 85.50                 │   │  ← Editable amount field
│  └─────────────────────────┘   │
│                                 │
│  Category                       │
│  ┌─────────────────────────┐   │
│  │ Groceries            ▼  │   │  ← Category picker
│  └─────────────────────────┘   │
│                                 │
│  Type                           │
│  ┌──────────┬──────────┐       │
│  │  Credit  │  Debit   │       │  ← Segmented control
│  └──────────┴──────────┘       │
│                                 │
│  Date                           │
│  ┌─────────────────────────┐   │
│  │ Jan 30, 2026  10:30 AM  │   │  ← Date picker
│  └─────────────────────────┘   │
│                                 │
│  Merchant                       │
│  ┌─────────────────────────┐   │
│  │ Costco                  │   │  ← Text field
│  └─────────────────────────┘   │
│                                 │
│  Description                    │
│  ┌─────────────────────────┐   │
│  │ Weekly groceries        │   │  ← Multi-line text field
│  │                         │   │
│  └─────────────────────────┘   │
│                                 │
└─────────────────────────────────┘
```

### Visual Design

| Element | Specification |
|---------|---------------|
| **Amount (View)** | 34pt, semibold, color based on type |
| **Category Icon** | 48pt SF Symbol, category color |
| **Section Headers** | Uppercase, secondary label color |
| **Detail Rows** | Standard iOS list style |
| **Receipt Button** | Full-width, bordered button style |
| **Delete Button** | Full-width, red text, bordered |
| **Edit Fields** | iOS native form style |

### Receipt States

| State | Display |
|-------|---------|
| **No Receipt** | "Add Receipt" button with camera icon |
| **Has Receipt** | "View Receipt" button with paperclip icon |
| **Uploading** | Progress indicator |
| **Upload Failed** | Error message with retry |
| **Loading Receipt** | Progress indicator |

## API Requirements

### PUT /expense/{id}

**Request:**
```http
PUT /expense/{id}
Content-Type: application/json

{
  "amount": 90.00,
  "category": "Groceries",
  "transaction_type": "Debit",
  "created_at": "2026-01-30T10:30:00Z",
  "merchant": "Costco",
  "description": "Weekly groceries - updated"
}
```

**Response:**
```json
{
  "message": "Expense updated successfully"
}
```

### DELETE /expense/{id}

**Request:**
```http
DELETE /expense/{id}
```

**Response:**
```json
{
  "message": "Expense deleted successfully"
}
```

### Receipt Upload Flow (S3 Pre-signed URL)

#### Step 1: Request Upload URL

**Request:**
```http
POST /expense/{id}/receipt/upload-url
Content-Type: application/json

{
  "filename": "receipt.jpg",
  "content_type": "image/jpeg"
}
```

**Response:**
```json
{
  "upload_url": "https://s3.amazonaws.com/bucket/path?X-Amz-Signature=...",
  "expires_in": 300
}
```

#### Step 2: Upload to S3

**Request:**
```http
PUT {upload_url}
Content-Type: image/jpeg

<binary file data>
```

**Response:** `200 OK` (from S3)

#### Step 3: Confirm Upload

**Request:**
```http
POST /expense/{id}/receipt/confirm
Content-Type: application/json

{
  "filename": "receipt.jpg"
}
```

**Response:**
```json
{
  "message": "Receipt saved successfully",
  "receipt_id": "receipt_xyz789"
}
```

### Receipt Download Flow

#### Request View URL

**Request:**
```http
GET /expense/{id}/receipt/view-url
```

**Response:**
```json
{
  "view_url": "https://s3.amazonaws.com/bucket/path?X-Amz-Signature=...",
  "expires_in": 3600,
  "content_type": "image/jpeg"
}
```

## Technical Requirements

### Form Validation

| Field | Validation |
|-------|------------|
| Amount | Required, > 0, max 2 decimal places |
| Category | Required, must be valid enum |
| Type | Required |
| Date | Required |
| Merchant | Optional, max 100 chars |
| Description | Optional, max 500 chars |

### Receipt Handling

- **Max file size**: 10 MB
- **Compression**: Images compressed before upload
- **Formats**: JPEG, PNG, PDF
- **URL expiry**: Handle expired URLs gracefully

### Unsaved Changes

- Track dirty state when editing
- Show confirmation alert if navigating away with changes
- Options: "Save", "Discard", "Cancel"

## Error Handling

| Scenario | Handling |
|----------|----------|
| Save failed | Show error, keep edit mode |
| Upload URL request failed | Show error with retry option |
| S3 upload failed | Show error with retry option |
| Confirm upload failed | Show error with retry option |
| View URL request failed | Show error with retry |
| Delete failed | Show error with retry |

## Dependencies

- **Receives from**: Transactions View (navigation with Transaction object)
- **Returns to**: Transactions View (after delete, triggers refresh)
- **Uses**: PhotosUI for image picker, UniformTypeIdentifiers for file types, QuickLook for PDF viewing
