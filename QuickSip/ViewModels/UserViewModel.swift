//
//  UserViewModel.swift
//  QuickSip
//
//  Created by Seun Adekunle on 4/12/25.
//

import Foundation
import SwiftUI
import Combine
import FirebaseAuth

class UserViewModel: ObservableObject {
    private let firebaseService = FirebaseService.shared
    
    @Published var currentUser: User?
    @Published var userOrders: [Order] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    var cancellables = Set<AnyCancellable>()
    
    // Fetch current user profile
    func fetchCurrentUser() {
        guard let firebaseUser = Auth.auth().currentUser else {
            self.errorMessage = "No logged in user"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        firebaseService.getUser(userId: firebaseUser.uid) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let user):
                    self?.currentUser = user
                    self?.setupOrderUpdates()
                case .failure(let error):
                    self?.errorMessage = "Failed to fetch user: \(error.localizedDescription)"
                }
            }
        }
    }
    
    // Create new user profile after authentication
    func createUserProfile(name: String, email: String) {
        guard let firebaseUser = Auth.auth().currentUser else {
            self.errorMessage = "No logged in user"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        firebaseService.createUser(name: name, email: email, userId: firebaseUser.uid) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let user):
                    self?.currentUser = user
                case .failure(let error):
                    self?.errorMessage = "Failed to create user profile: \(error.localizedDescription)"
                }
            }
        }
    }
    
    // Fetch user's order history
    func fetchUserOrders(completion: (() -> Void)? = nil) {
        guard let userId = currentUser?.id else {
            self.errorMessage = "No current user"
            completion?()
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        firebaseService.getUserOrders(userId: userId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let orders):
                    // Update current user with merged orders
                    if let currentUser = self?.currentUser {
                        let updatedUser = currentUser.updatingOrders(orders)
                        self?.currentUser = updatedUser
                        self?.userOrders = updatedUser.orderHistory.sorted(by: { $0.timestamp > $1.timestamp })
                    } else {
                        self?.userOrders = orders.sorted(by: { $0.timestamp > $1.timestamp })
                    }
                case .failure(let error):
                    self?.errorMessage = "Failed to fetch orders: \(error.localizedDescription)"
                }
                
                completion?()
            }
        }
    }
    
    // Filter orders by status
    func ordersWithStatus(_ status: String) -> [Order] {
        if status.lowercased() == "all" {
            return userOrders
        }
        return userOrders.filter { $0.status.lowercased() == status.lowercased() }
    }
    
    // Get order count by status
    func orderCountWithStatus(_ status: String) -> Int {
        return ordersWithStatus(status).count
    }
    
    // Get total spent on orders
    var totalSpent: Double {
        return userOrders.reduce(0) { $0 + $1.price }
    }
    
    // Get most ordered drink
    var favoriteOrder: String? {
        let drinkCounts = userOrders
            .map { $0.drinkType }
            .reduce(into: [String: Int]()) { counts, drink in
                counts[drink, default: 0] += 1
            }
        
        return drinkCounts.max(by: { $0.value < $1.value })?.key
    }
    
    // Add order to user's history
    func addOrderToHistory(_ order: Order) {
        guard let user = currentUser else {
            self.errorMessage = "No current user"
            return
        }
        
        // First add the order locally
        let updatedUser = user.addingOrder(order)
        
        isLoading = true
        errorMessage = nil
        
        // Then update in Firestore
        firebaseService.updateUser(updatedUser) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success:
                    self?.currentUser = updatedUser
                    self?.userOrders.insert(order, at: 0)
                    
                    // Fetch latest orders from cloud to ensure we're in sync
                    self?.fetchUserOrders()
                case .failure(let error):
                    self?.errorMessage = "Failed to update user: \(error.localizedDescription)"
                }
            }
        }
    }

    // Setup real-time order updates
    func setupOrderUpdates() {
        guard let userId = currentUser?.id else { return }
        
        // Listen for order status changes
        StatusUpdateService.shared.$currentOrderStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                // Refresh orders when status changes
                self?.fetchUserOrders()
            }
            .store(in: &cancellables)
    }
} 