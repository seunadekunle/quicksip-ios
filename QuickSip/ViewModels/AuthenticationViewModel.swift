//
//  AuthenticationViewModel.swift
//  QuickSip
//
//  Created by Seun Adekunle on 4/12/25.
//

import Foundation
import Combine
import SwiftUI
import FirebaseAuth

class AuthenticationViewModel: ObservableObject {
    // Services
    private let authService = AuthenticationService.shared
    private let userViewModel = UserViewModel()
    
    // Published properties
    @Published var isGoogleSignInProcessing = false
    @Published var navigateToHome = false
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Observe changes from AuthenticationService and publish them
        authService.$isAuthenticated
            .receive(on: RunLoop.main)
            .sink { [weak self] value in
                self?.isAuthenticated = value
                print("[VIEW MODEL] isAuthenticated changed to: \(value)")
            }
            .store(in: &cancellables)
            
        authService.$isLoading
            .receive(on: RunLoop.main)
            .sink { [weak self] value in
                guard let self = self else { return }
                self.isLoading = value || self.isGoogleSignInProcessing
            }
            .store(in: &cancellables)
            
        // Add observation for isGoogleSignInProcessing changes
        $isGoogleSignInProcessing
            .sink { [weak self] value in
                guard let self = self else { return }
                self.isLoading = self.authService.isLoading || value
            }
            .store(in: &cancellables)
            
        authService.$errorMessage
            .receive(on: RunLoop.main)
            .sink { [weak self] value in
                self?.errorMessage = value
            }
            .store(in: &cancellables)
            
        // Initialize values
        self.isAuthenticated = authService.isAuthenticated
        self.isLoading = authService.isLoading
        self.errorMessage = authService.errorMessage
        
        print("[VIEW MODEL] Initialized with isAuthenticated: \(self.isAuthenticated)")
    }
    
    // Get current user ID
    var currentUserId: String? {
        authService.user?.uid
    }
    
    // MARK: - Authentication Methods
    
    /// Check for existing authentication session and restore it
    func checkAndRestoreSession() {
        // Use the improved AuthenticationService method to restore authentication
        authService.restoreAuthSession()
        
        // If we have a user after restoration attempt, fetch their profile
        if authService.user != nil {
            userViewModel.fetchCurrentUser()
        }
    }
    
    func signInWithGoogle(completion: @escaping (Bool) -> Void) {
        isGoogleSignInProcessing = true
        
        authService.signInWithGoogle { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isGoogleSignInProcessing = false
                
                switch result {
                case .success:
                    // Fetch user profile
                    self.userViewModel.fetchCurrentUser()
                    
                    // Trigger navigation to home
                    self.navigateToHome = true
                    print("[VIEW MODEL] Google Sign In successful, navigateToHome set to true")
                    
                    completion(true)
                case .failure:
                    completion(false)
                }
            }
        }
    }
    
    func signOut(completion: @escaping (Bool) -> Void) {
        let result = authService.signOut()
        
        switch result {
        case .success:
            navigateToHome = false
            completion(true)
        case .failure:
            completion(false)
        }
    }
} 