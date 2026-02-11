//
//  PaymentScheduleViewModel.swift
//  HomeApp
//
//  Family Expense Tracker
//

import SwiftUI
import Observation

@Observable
class PaymentScheduleViewModel {
    // Data
    var schedules: [PaymentSchedule] = []
    
    // UI State
    var isLoading: Bool = false
    var error: APIError?
    var isSaving: Bool = false
    
    // Dependencies
    private let apiService = APIService.shared
    
    // MARK: - Actions
    
    func loadSchedules() async {
        guard !isLoading else { return }
        
        isLoading = true
        error = nil
        
        do {
            schedules = try await apiService.fetchPaymentSchedules()
        } catch {
            self.error = error as? APIError ?? .unknown
        }
        
        isLoading = false
    }
    
    func createSchedule(_ schedule: PaymentScheduleCreate) async -> Bool {
        isSaving = true
        defer { isSaving = false }
        
        do {
            try await apiService.createPaymentSchedule(schedule)
            await loadSchedules()
            return true
        } catch {
            self.error = error as? APIError ?? .unknown
            return false
        }
    }
    
    func updateSchedule(id: String, _ schedule: PaymentScheduleCreate) async -> Bool {
        isSaving = true
        defer { isSaving = false }
        
        do {
            try await apiService.updatePaymentSchedule(id: id, schedule)
            await loadSchedules()
            return true
        } catch {
            self.error = error as? APIError ?? .unknown
            return false
        }
    }
    
    func deleteSchedule(id: String) async -> Bool {
        do {
            try await apiService.deletePaymentSchedule(id: id)
            schedules.removeAll { $0.id == id }
            return true
        } catch {
            self.error = error as? APIError ?? .unknown
            return false
        }
    }
}
