//
//  QuickSipApp.swift
//  QuickSip
//
//  Created by Seun Adekunle on 4/12/25.
//

import SwiftUI
import Firebase
import GoogleSignIn

@main
struct QuickSipApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authViewModel = AuthenticationViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
                .preferredColorScheme(.light)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
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
