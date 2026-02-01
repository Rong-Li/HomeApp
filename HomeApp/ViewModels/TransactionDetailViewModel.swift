//
//  TransactionDetailViewModel.swift
//  HomeApp
//
//  Family Expense Tracker
//

import SwiftUI
import Observation

@Observable
class TransactionDetailViewModel {
    var transaction: Transaction
    var isLoading = false
    var isSaving = false
    var isDeleting = false
    var error: String?
    
    // Receipt state
    var receiptState: ReceiptState = .none
    var uploadProgress: Double = 0
    
    enum ReceiptState {
        case none
        case hasReceipt
        case loadingUrl
        case uploading
        case error(String)
    }
    
    private let apiService = APIService.shared
    
    init(transaction: Transaction) {
        self.transaction = transaction
        self.receiptState = transaction.hasReceipt ? .hasReceipt : .none
    }
    
    var formattedFullDateTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: transaction.createdAt)
    }
    
    // MARK: - Actions
    
    func saveTransaction(_ updated: Transaction) async throws {
        isSaving = true
        error = nil
        defer { isSaving = false }
        
        try await apiService.updateTransaction(updated)
        transaction = updated
    }
    
    func deleteTransaction() async throws {
        isDeleting = true
        error = nil
        defer { isDeleting = false }
        
        try await apiService.deleteTransaction(id: transaction.id)
    }
    
    // MARK: - Receipt Upload
    
    func uploadReceipt(data: Data, filename: String, contentType: String) async {
        receiptState = .uploading
        uploadProgress = 0
        
        do {
            // Step 1: Get pre-signed upload URL
            let uploadUrl = try await apiService.getReceiptUploadUrl(
                transactionId: transaction.id,
                filename: filename,
                contentType: contentType
            )
            uploadProgress = 0.3
            
            // Step 2: Upload to S3
            try await apiService.uploadToS3(
                url: uploadUrl,
                data: data,
                contentType: contentType
            )
            uploadProgress = 0.7
            
            // Step 3: Confirm upload
            let receiptId = try await apiService.confirmReceiptUpload(
                transactionId: transaction.id,
                filename: filename
            )
            uploadProgress = 1.0
            
            await MainActor.run {
                transaction.receiptId = receiptId
                receiptState = .hasReceipt
            }
            
        } catch {
            await MainActor.run {
                receiptState = .error("Upload failed. Please try again.")
            }
        }
    }
    
    func loadReceiptUrl() async -> APIService.ViewUrlResponse? {
        receiptState = .loadingUrl
        
        do {
            let response = try await apiService.getReceiptViewUrl(transactionId: transaction.id)
            await MainActor.run {
                receiptState = .hasReceipt
            }
            return response
        } catch {
            await MainActor.run {
                receiptState = .error("Failed to load receipt")
            }
            return nil
        }
    }
}
