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
    func fetchUserOrders() {
        guard let userId = currentUser?.id else {
            self.errorMessage = "No current user"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        firebaseService.getUserOrders(userId: userId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let orders):
                    self?.userOrders = orders
                case .failure(let error):
                    self?.errorMessage = "Failed to fetch orders: \(error.localizedDescription)"
                }
            }
        }
    }
    
    // Add order to user's history
    func addOrderToHistory(_ order: Order) {
        guard var user = currentUser else {
            self.errorMessage = "No current user"
            return
        }
        
        let updatedUser = user.addingOrder(order)
        
        isLoading = true
        errorMessage = nil
        
        firebaseService.updateUser(updatedUser) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success:
                    self?.currentUser = updatedUser
                    self?.userOrders.insert(order, at: 0)
                case .failure(let error):
                    self?.errorMessage = "Failed to update user: \(error.localizedDescription)"
                }
            }
        }
    }
} 