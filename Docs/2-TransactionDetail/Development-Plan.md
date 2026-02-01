# Transaction Detail View - Development Plan

## Overview

Implementation plan for the Transaction Detail View—viewing, editing, receipt management (S3 pre-signed URLs), and deletion.

## Phase 1: View Mode

### 1.1 Structure
- `Views/TransactionDetail/TransactionDetailView.swift` - ScrollView with header, details, receipt, delete sections
- Header: Category icon, formatted amount (colored), category name
- Details: GroupBox with Type, Date, Merchant, Description rows
- Edit toolbar button

### 1.2 DetailRow Component
- Reusable row with label and value

---

## Phase 2: Edit Mode

### 2.1 Edit Form
- `Views/TransactionDetail/TransactionEditForm.swift` - Form with amount, category picker, type segmented control, date picker, merchant, description fields

### 2.2 ViewModel
- `ViewModels/TransactionDetailViewModel.swift` - Holds transaction, saveTransaction, deleteTransaction, receipt state

### 2.3 Edit Flow
- Edit/Cancel/Done toolbar, unsaved changes confirmation

---

## Phase 3: Receipt Management

### 3.1 Receipt Section
- `Views/TransactionDetail/ReceiptSectionView.swift` - States: none (Add button), hasReceipt (View button), loading, uploading, error
- Add: PhotosPicker + document picker for PDF
- Upload flow: get upload URL → upload to S3 → confirm with backend

### 3.2 Receipt Viewer
- `Views/TransactionDetail/ReceiptViewerView.swift` - Get view URL from API, display image or PDF (WKWebView), ShareLink

### 3.3 File Pickers
- PhotosPicker for images
- UIDocumentPickerViewController for PDFs (ReceiptFilePicker)

---

## Phase 4: Delete

- Delete button in section
- Confirmation alert
- API: DELETE /expense/{id}
- Dismiss and trigger list refresh on success

---

## Phase 5: API Service Extensions

Add to APIService:
- updateTransaction (PUT /expense/{id})
- deleteTransaction (DELETE /expense/{id})
- getReceiptUploadUrl
- uploadToS3
- confirmReceiptUpload
- getReceiptViewUrl

---

## Implementation Checklist

### Phase 1: View Mode
- [ ] TransactionDetailView structure
- [ ] Header section
- [ ] Details section
- [ ] DetailRow component

### Phase 2: Edit Mode
- [ ] TransactionEditForm
- [ ] TransactionDetailViewModel
- [ ] Edit/cancel/done flow
- [ ] Unsaved changes handling

### Phase 3: Receipt Management
- [ ] ReceiptSectionView
- [ ] ReceiptImagePicker (PhotosPicker)
- [ ] ReceiptFilePicker (UIDocumentPicker)
- [ ] ReceiptViewerView
- [ ] S3 upload flow

### Phase 4: Delete
- [ ] Delete button and confirmation
- [ ] API integration

### Phase 5: API
- [ ] All receipt and transaction methods
