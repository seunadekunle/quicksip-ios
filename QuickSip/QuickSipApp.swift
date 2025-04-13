//
//  QuickSipApp.swift
//  QuickSip
//
//  Created by Seun Adekunle on 4/12/25.
//

import SwiftUI
import Firebase
import GoogleSignIn
import FirebaseAppCheck
import Combine

@main
struct QuickSipApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authViewModel = AuthenticationViewModel()
    @StateObject private var userViewModel = UserViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(userViewModel)
                .onAppear {
                    // Pass the authViewModel to the AppDelegate
                    delegate.authViewModel = authViewModel
                    
                    // Observe authentication changes
                    authViewModel.$isAuthenticated
                        .sink { isAuthenticated in
                            if isAuthenticated {
                                userViewModel.fetchCurrentUser()
                            } else {
                                // Clear user data when logged out
                                userViewModel.currentUser = nil
                                userViewModel.userOrders = []
                            }
                        }
                        .store(in: &userViewModel.cancellables)
                }
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
                .preferredColorScheme(.light)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    var authViewModel: AuthenticationViewModel?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    let providerFactory = AppCheckDebugProviderFactory()
    AppCheck.setAppCheckProviderFactory(providerFactory)

    FirebaseApp.configure()
    
    // Restore authentication session - use our new comprehensive method
    AuthenticationService.shared.restoreAuthSession()
        
        // Enforce light mode at UIKit level
        if #available(iOS 15.0, *) {
            let scenes = UIApplication.shared.connectedScenes
            scenes.forEach { scene in
                if let windowScene = scene as? UIWindowScene {
                    windowScene.windows.forEach { window in
                        window.overrideUserInterfaceStyle = .light
                    }
                }
            }
        } else {
            UIApplication.shared.windows.forEach { window in
                window.overrideUserInterfaceStyle = .light
            }
        }
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}
