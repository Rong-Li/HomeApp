//
//  ReceiptSectionView.swift
//  HomeApp
//
//  Family Expense Tracker
//

import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct ReceiptSectionView: View {
    @Bindable var viewModel: TransactionDetailViewModel
    
    @State private var showImagePicker = false
    @State private var showFilePicker = false
    @State private var showActionSheet = false
    @State private var showReceiptViewer = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("RECEIPT")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            GroupBox {
                switch viewModel.receiptState {
                case .none:
                    addReceiptButton
                    
                case .hasReceipt:
                    viewReceiptButton
                    
                case .loadingUrl:
                    HStack {
                        ProgressView()
                        Text("Loading...")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    
                case .uploading:
                    VStack(spacing: 8) {
                        ProgressView(value: viewModel.uploadProgress)
                        Text("Uploading...")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    
                case .error(let message):
                    VStack(spacing: 8) {
                        Text(message)
                            .foregroundStyle(.red)
                            .font(.caption)
                        Button("Try Again") {
                            showActionSheet = true
                        }
                    }
                    .padding()
                }
            }
        }
        .confirmationDialog("Add Receipt", isPresented: $showActionSheet) {
            Button("Choose from Photos") {
                showImagePicker = true
            }
            Button("Choose File") {
                showFilePicker = true
            }
        }
        .photosPicker(isPresented: $showImagePicker, selection: $selectedPhotoItem, matching: .images)
        .onChange(of: selectedPhotoItem) { _, newValue in
            if let item = newValue {
                Task {
                    await handlePhotoSelection(item)
                }
            }
        }
        .sheet(isPresented: $showFilePicker) {
            ReceiptFilePicker { data, filename, contentType in
                Task {
                    await viewModel.uploadReceipt(data: data, filename: filename, contentType: contentType)
                }
            }
        }
        .sheet(isPresented: $showReceiptViewer) {
            ReceiptViewerView(viewModel: viewModel)
        }
    }
    
    private var addReceiptButton: some View {
        Button {
            showActionSheet = true
        } label: {
            Label("Add Receipt", systemImage: "camera.fill")
                .frame(maxWidth: .infinity)
                .padding()
        }
    }
    
    private var viewReceiptButton: some View {
        Button {
            showReceiptViewer = true
        } label: {
            Label("View Receipt", systemImage: "paperclip")
                .frame(maxWidth: .infinity)
                .padding()
        }
    }
    
    private func handlePhotoSelection(_ item: PhotosPickerItem) async {
        guard let data = try? await item.loadTransferable(type: Data.self) else { return }
        
        // Compress image
        if let image = UIImage(data: data),
           let compressedData = image.jpegData(compressionQuality: 0.7) {
            await viewModel.uploadReceipt(
                data: compressedData,
                filename: "receipt_\(Date().timeIntervalSince1970).jpg",
                contentType: "image/jpeg"
            )
        }
    }
}

// MARK: - Receipt File Picker

struct ReceiptFilePicker: UIViewControllerRepresentable {
    let onFilePicked: (Data, String, String) -> Void
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf, .jpeg, .png])
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onFilePicked: onFilePicked, dismiss: dismiss)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onFilePicked: (Data, String, String) -> Void
        let dismiss: DismissAction
        
        init(onFilePicked: @escaping (Data, String, String) -> Void, dismiss: DismissAction) {
            self.onFilePicked = onFilePicked
            self.dismiss = dismiss
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            
            guard url.startAccessingSecurityScopedResource() else { return }
            defer { url.stopAccessingSecurityScopedResource() }
            
            guard let data = try? Data(contentsOf: url) else { return }
            
            let filename = url.lastPathComponent
            let contentType: String
            
            switch url.pathExtension.lowercased() {
            case "pdf": contentType = "application/pdf"
            case "png": contentType = "image/png"
            default: contentType = "image/jpeg"
            }
            
            onFilePicked(data, filename, contentType)
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            dismiss()
        }
    }
}

#Preview {
    ReceiptSectionView(viewModel: TransactionDetailViewModel(
        transaction: Transaction(
            id: "1",
            amount: 85.50,
            category: .groceries,
            transactionType: .debit,
            createdAt: Date(),
            merchant: "Costco",
            description: nil,
            receiptId: nil
        )
    ))
    .padding()
}
