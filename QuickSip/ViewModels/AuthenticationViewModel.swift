//
//  AuthenticationViewModel.swift
//  QuickSip
//
//  Created by Seun Adekunle on 4/12/25.
//

import Foundation
import Combine
import SwiftUI

class AuthenticationViewModel: ObservableObject {
    // Services
    private let authService = AuthenticationService.shared
    private let userViewModel = UserViewModel()
    
    // Published properties
    @Published var isGoogleSignInProcessing = false
    
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
    
    // MARK: - Authentication Methods
    
    func signInWithGoogle(completion: @escaping (Bool) -> Void) {
        isGoogleSignInProcessing = true
        
        authService.signInWithGoogle { [weak self] result in
            DispatchQueue.main.async {
                self?.isGoogleSignInProcessing = false
                
                switch result {
                case .success:
                    // Fetch user profile
                    self?.userViewModel.fetchCurrentUser()
                    
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
            completion(true)
        case .failure:
            completion(false)
        }
    }
} 