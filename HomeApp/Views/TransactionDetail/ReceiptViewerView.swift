//
//  ReceiptViewerView.swift
//  HomeApp
//
//  Family Expense Tracker
//

import SwiftUI
import WebKit

struct ReceiptViewerView: View {
    @Bindable var viewModel: TransactionDetailViewModel
    
    @Environment(\.dismiss) private var dismiss
    @State private var viewUrl: URL?
    @State private var isLoading = true
    @State private var error: String?
    @State private var contentType: String = "image/jpeg"
    
    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Loading receipt...")
                } else if let error = error {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundStyle(.red)
                        Text(error)
                        Button("Retry") {
                            Task { await loadReceipt() }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else if let url = viewUrl {
                    if contentType == "application/pdf" {
                        PDFViewer(url: url)
                    } else {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            case .failure:
                                Text("Failed to load image")
                            @unknown default:
                                EmptyView()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Receipt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") { dismiss() }
                }
                
                if let url = viewUrl {
                    ToolbarItem(placement: .topBarTrailing) {
                        ShareLink(item: url) {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }
            }
        }
        .task {
            await loadReceipt()
        }
    }
    
    private func loadReceipt() async {
        isLoading = true
        error = nil
        
        if let response = await viewModel.loadReceiptUrl() {
            viewUrl = URL(string: response.viewUrl)
            contentType = response.contentType
        } else {
            error = "Failed to load receipt"
        }
        
        isLoading = false
    }
}

// MARK: - PDF Viewer

struct PDFViewer: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

#Preview {
    ReceiptViewerView(viewModel: TransactionDetailViewModel(
        transaction: Transaction(
            id: "1",
            amount: 85.50,
            category: .groceries,
            transactionType: .debit,
            createdAt: Date(),
            merchant: "Costco",
            description: nil,
            receiptId: "abc123"
        )
    ))
}
