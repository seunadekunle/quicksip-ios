//
//  ContentView.swift
//  QuickSip
//
//  Created by Seun Adekunle on 4/12/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthenticationViewModel()
    
    var body: some View {
        // Display either the home screen or login based on authentication state
        Group {
            if authViewModel.isAuthenticated {
                // Main app content
                TabView {
                    NavigationStack {
                        HomeView()
                    }
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                    
                    NavigationStack {
                        Text("Orders")
                            .navigationTitle("Your Orders")
                    }
                    .tabItem {
                        Label("Orders", systemImage: "list.bullet")
                    }
                    
                    NavigationStack {
                        ProfileView()
                    }
                    .tabItem {
                        Label("Profile", systemImage: "person")
                    }
                }
                .accentColor(AppColors.primary)
            } else {
                // Authentication screen
                LoginView()
            }
        }
    }
}

#Preview {
    ContentView()
}
