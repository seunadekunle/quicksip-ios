//
//  OrderViewModel.swift
//  QuickSip
//
//  Created by Seun Adekunle on 4/12/25.
//

import Foundation
import SwiftUI
import Combine

class OrderViewModel: ObservableObject {
    private let firebaseService = FirebaseService.shared
    
    @Published var order: Order?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Create a new order
    func createOrder(userId: String, drinkType: String, location: String, paymentMethod: String, additionalRequests: String?) {
        isLoading = true
        errorMessage = nil
        
        let newOrder = Order(
            userId: userId,
            drinkType: drinkType,
            location: location,
            paymentMethod: paymentMethod,
            additionalRequests: additionalRequests
        )
        
        firebaseService.createOrder(order: newOrder) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let order):
                    self?.order = order
                case .failure(let error):
                    self?.errorMessage = "Failed to create order: \(error.localizedDescription)"
                }
            }
        }
    }
    
    // Fetch an order by ID
    func fetchOrder(orderId: String) {
        isLoading = true
        errorMessage = nil
        
        firebaseService.getOrder(orderId: orderId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let order):
                    self?.order = order
                case .failure(let error):
                    self?.errorMessage = "Failed to fetch order: \(error.localizedDescription)"
                }
            }
        }
    }
    
    // Update order status
    func updateOrderStatus(orderId: String, status: Order.Status) {
        isLoading = true
        errorMessage = nil
        
        firebaseService.updateOrderStatus(orderId: orderId, status: status) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success:
                    // Update the local order object with the new status
                    if var updatedOrder = self?.order, updatedOrder.id == orderId {
                        // We'd need to create a new order with updated status
                        // This is a simplification - in a real app, we might use a different approach
                    }
                case .failure(let error):
                    self?.errorMessage = "Failed to update order status: \(error.localizedDescription)"
                }
            }
        }
    }
} 