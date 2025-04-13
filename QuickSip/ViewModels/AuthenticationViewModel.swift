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
    
    // Computed properties
    var isAuthenticated: Bool {
        authService.isAuthenticated
    }
    
    var isLoading: Bool {
        authService.isLoading || isGoogleSignInProcessing
    }
    
    var errorMessage: String? {
        authService.errorMessage
    }
    
    // Get current user ID
    var currentUserId: String? {
        authService.user?.uid
    }
    
    // MARK: - Authentication Methods
    
    /// Check for existing authentication session and restore it
    func checkAndRestoreSession() {
        // Firebase Auth should automatically restore the session, but we need to
        // make sure our ViewModel state is in sync with Firebase Auth state
        if authService.user != nil {
            // User is already signed in, fetch their profile
            userViewModel.fetchCurrentUser()
        }
    }
    
    func signInWithGoogle(completion: @escaping (Bool) -> Void) {
        isGoogleSignInProcessing = true
        
        authService.signInWithGoogle { [weak self] result in
            DispatchQueue.main.async {
                self?.isGoogleSignInProcessing = false
                
                switch result {
                case .success:
                    // Fetch user profile
                    self?.userViewModel.fetchCurrentUser()
                    
                    // Trigger navigation to home
                    self?.navigateToHome = true
                    
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