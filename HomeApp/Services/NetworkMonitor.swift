//
//  NetworkMonitor.swift
//  HomeApp
//
//  Family Expense Tracker
//

import Network
import SwiftUI

@Observable
class NetworkMonitor {
    static let shared = NetworkMonitor()
    
    var isConnected: Bool = true
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }
}
