//
//  StatusUpdateService.swift
//  QuickSip
//
//  Created by Seun Adekunle on 4/22/25.
//

import Foundation
import Firebase
import FirebaseDatabase
import Combine

class StatusUpdateService: ObservableObject {
    static let shared = StatusUpdateService()
    
    private let database = Database.database().reference()
    private var statusListeners: [String: DatabaseHandle] = [:]
    
    // Published properties for order updates
    @Published var currentOrderStatus: String?
    @Published var isConnected: Bool = true
    @Published var lastUpdated: Date?
    @Published var errorMessage: String?
    
    private init() {
        // Monitor connection state
        let connectedRef = Database.database().reference(withPath: ".info/connected")
        connectedRef.observe(.value, with: { [weak self] snapshot in
            self?.isConnected = snapshot.value as? Bool ?? false
        })
    }
    
    // MARK: - Public API
    
    /// Start listening for updates on a specific order
    func startListeningForOrderUpdates(orderId: String) {
        // Remove any existing listener for this order
        stopListeningForOrderUpdates(orderId: orderId)
        
        // Create a reference to this order in the Realtime Database
        let orderRef = database.child("orders").child(orderId)
        
        // Listen for status updates
        let handle = orderRef.child("status").observe(.value) { [weak self] snapshot in
            guard let self = self else { return }
            
            if snapshot.exists() {
                if let status = snapshot.value as? String {
                    DispatchQueue.main.async {
                        self.currentOrderStatus = status
                        self.lastUpdated = Date()
                        self.errorMessage = nil
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Invalid status format"
                    }
                }
            } else {
                // Initialize status if it doesn't exist yet
                self.createInitialOrderStatus(orderId: orderId)
            }
        }
        
        // Store the listener handle
        statusListeners[orderId] = handle
        
        // Set up error handling
        orderRef.child("status").observe(.childRemoved) { [weak self] _ in
            self?.handleDisconnection()
        }
    }
    
    /// Stop listening for updates on a specific order
    func stopListeningForOrderUpdates(orderId: String) {
        if let handle = statusListeners[orderId] {
            database.child("orders").child(orderId).removeObserver(withHandle: handle)
            statusListeners.removeValue(forKey: orderId)
        }
    }
    
    /// Update the status of an order
    func updateOrderStatus(orderId: String, status: Order.Status, completion: @escaping (Error?) -> Void) {
        let orderRef = database.child("orders").child(orderId)
        
        // Update both Realtime Database for live updates
        orderRef.child("status").setValue(status.rawValue) { error, _ in
            // Also update Firestore for persistence
            if error == nil {
                FirebaseService.shared.updateOrderStatus(orderId: orderId, status: status) { result in
                    switch result {
                    case .success:
                        completion(nil)
                    case .failure(let error):
                        completion(error)
                    }
                }
            } else {
                completion(error)
            }
        }
    }
    
    // MARK: - Private helpers
    
    private func createInitialOrderStatus(orderId: String) {
        // Fetch the current status from Firestore
        FirebaseService.shared.getOrder(orderId: orderId) { [weak self] result in
            switch result {
            case .success(let order):
                // Initialize the real-time status with the current status from Firestore
                self?.database.child("orders").child(orderId).child("status").setValue(order.status)
                DispatchQueue.main.async {
                    self?.currentOrderStatus = order.status
                    self?.lastUpdated = Date()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.errorMessage = "Failed to fetch initial status: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func handleDisconnection() {
        DispatchQueue.main.async { [weak self] in
            self?.isConnected = false
            self?.errorMessage = "Connection to status updates lost"
        }
    }
    
    // MARK: - Deinitializer
    
    deinit {
        // Clean up all observers when this service is deallocated
        for (orderId, handle) in statusListeners {
            database.child("orders").child(orderId).removeObserver(withHandle: handle)
        }
    }
} 