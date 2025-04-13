//
//  AuthenticationService.swift
//  QuickSip
//
//  Created by Seun Adekunle on 4/12/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine
import GoogleSignIn
import FirebaseCore

class AuthenticationService: ObservableObject {
    static let shared = AuthenticationService()
    
    @Published var user: FirebaseAuth.User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let firebaseService = FirebaseService.shared
    private var authStateListener: AuthStateDidChangeListenerHandle?
    
    private init() {
        setupAuthStateListener()
    }
    
    deinit {
        // Remove auth state listener when service is deallocated
        if let handle = authStateListener {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    /// Sets up the Firebase Auth state listener to track authentication state changes
    /// This should be called early in the app lifecycle
    func setupAuthStateListener() {
        // Ensure we remove any existing listener before adding a new one
        if let handle = authStateListener {
            Auth.auth().removeStateDidChangeListener(handle)
        }
        
        print("[AUTH] Setting up auth state listener...")
        
        // Listen for authentication state changes
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] (_, user) in
            DispatchQueue.main.async {
                print("[AUTH STATE LISTENER] Listener fired.")
                
                let wasAuthenticated = self?.isAuthenticated ?? false
                self?.user = user
                self?.isAuthenticated = user != nil
                
                // Log authentication state change
                if wasAuthenticated != (user != nil) {
                    print("[AUTH STATE LISTENER] Authentication state changed: \(wasAuthenticated) -> \(user != nil)")
                }
                
                if user != nil {
                    print("[AUTH STATE LISTENER] User IS authenticated: \(user?.uid ?? "unknown")")
                    print("[AUTH STATE LISTENER] Auth Provider: \(user?.providerData.first?.providerID ?? "unknown")")
                    print("[AUTH STATE LISTENER] Email: \(user?.email ?? "none")")
                } else {
                    print("[AUTH STATE LISTENER] User is NOT authenticated.")
                }
            }
        }
    }
    
    /// Attempt to restore any existing authentication session
    func restoreAuthSession() {
        print("[AUTH] restoreAuthSession called")
        
        // Ensure auth state listener is set up (this does the heavy lifting)
        setupAuthStateListener()
        
        // Check if we already have a Firebase user
        if let currentUser = Auth.auth().currentUser {
            print("[AUTH] Firebase session already exists for user: \(currentUser.uid)")
            return
        }
        
        print("[AUTH] No active Firebase session, attempting to restore Google Sign-In")
        
        // Try to restore Google Sign-In session
        GIDSignIn.sharedInstance.restorePreviousSignIn { [weak self] user, error in
            if let error = error {
                print("[AUTH] Failed to restore Google Sign-In: \(error.localizedDescription)")
                return
            }
            
            guard let user = user,
                  let idToken = user.idToken?.tokenString else {
                print("[AUTH] No previous Google Sign-In session found")
                return
            }
            
            print("[AUTH] Found previous Google Sign-In, creating Firebase credential")
            
            // Create Firebase credential from the restored Google Sign-In
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: user.accessToken.tokenString
            )
            
            // Sign in to Firebase with the credential
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("[AUTH] Failed to sign in to Firebase with restored Google credential: \(error.localizedDescription)")
                    return
                }
                
                if let authResult = authResult {
                    print("[AUTH] Successfully restored Firebase session from Google Sign-In for user: \(authResult.user.uid)")
                }
            }
        }
    }
    
    // MARK: - User Authentication
    
    func signInWithGoogle(completion: @escaping (Result<User, Error>) -> Void) {
        isLoading = true
        errorMessage = nil
        
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            let error = NSError(domain: "AuthenticationService", code: 500, 
                               userInfo: [NSLocalizedDescriptionKey: "Firebase configuration error."])
            handleAuthError(error)
            completion(.failure(error))
            return
        }
        
        // Create Google Sign In configuration object
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            let error = NSError(domain: "AuthenticationService", code: 500, 
                               userInfo: [NSLocalizedDescriptionKey: "Cannot get root view controller."])
            handleAuthError(error)
            completion(.failure(error))
            return
        }
        
        // Start the sign in flow
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [weak self] result, error in
            guard let self = self else { return }
            
            if let error = error {
                self.handleAuthError(error)
                self.isLoading = false
                completion(.failure(error))
                return
            }
            
           guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                let error = NSError(domain: "AuthenticationService", code: 500, 
                                   userInfo: [NSLocalizedDescriptionKey: "Google authentication failed."])
                self.handleAuthError(error)
                self.isLoading = false
                completion(.failure(error))
                return
            }
            
            // Create Firebase credential
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                          accessToken: user.accessToken.tokenString)
            
            // Sign in with Firebase
            Auth.auth().signIn(with: credential) { [weak self] (authResult, error) in
                guard let self = self else { return }
                
                if let error = error {
                    self.handleAuthError(error)
                    self.isLoading = false
                    completion(.failure(error))
                    return
                }
                
                guard let authResult = authResult else {
                    let error = NSError(domain: "AuthenticationService", code: 500, 
                                       userInfo: [NSLocalizedDescriptionKey: "Firebase authentication failed."])
                    self.handleAuthError(error)
                    self.isLoading = false
                    completion(.failure(error))
                    return
                }
                
                guard let googleProfile = user.profile else {
                    let error = NSError(domain: "AuthenticationService", code: 500, 
                                       userInfo: [NSLocalizedDescriptionKey: "Unable to get Google profile."])
                    self.handleAuthError(error)
                    self.isLoading = false
                    completion(.failure(error))
                    return
                }
                
                // Check if the user exists in Firestore
                self.firebaseService.getUser(userId: authResult.user.uid) { result in
                    switch result {
                    case .success(let user):
                        // User exists, authentication successful
                        self.isLoading = false
                        self.errorMessage = nil
                        completion(.success(user))
                        
                    case .failure:
                        // User doesn't exist, create a new profile
                        let name = googleProfile.name ?? "Google User"
                        let email = googleProfile.email ?? ""
                        
                        self.createUserProfile(userId: authResult.user.uid, name: name, email: email) { result in
                            self.isLoading = false
                            
                            switch result {
                            case .success(let user):
                                self.errorMessage = nil
                                completion(.success(user))
                            case .failure(let error):
                                self.handleAuthError(error)
                                completion(.failure(error))
                            }
                        }
                    }
                }
            }
        }
    }
    
    func signOut() -> Result<Void, Error> {
        do {
            // Sign out from Firebase
            try Auth.auth().signOut()
            
            // Sign out from Google
            GIDSignIn.sharedInstance.signOut()
            
            return .success(())
        } catch let error {
            handleAuthError(error)
            return .failure(error)
        }
    }
    
    // MARK: - Helper Methods
    
    private func createUserProfile(userId: String, name: String, email: String, completion: @escaping (Result<User, Error>) -> Void) {
        firebaseService.createUser(name: name, email: email, userId: userId, completion: completion)
    }
    
    private func handleAuthError(_ error: Error) {
        isLoading = false
        
        let authError = error as NSError
        switch authError.code {
        case AuthErrorCode.networkError.rawValue:
            errorMessage = "Network error. Please check your connection and try again."
        default:
            errorMessage = "An error occurred: \(error.localizedDescription)"
        }
    }
} 
