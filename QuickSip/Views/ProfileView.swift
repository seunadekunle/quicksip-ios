//
//  ProfileView.swift
//  QuickSip
//
//  Created by Seun Adekunle on 4/12/25.
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var authViewModel = AuthenticationViewModel()
    @StateObject private var userViewModel = UserViewModel()
    @State private var showingSignOutAlert = false
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // User info and stats section
            VStack(spacing: 15) {
                // Profile Image
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .foregroundColor(AppColors.primary)
                
                // User name
                Text(userViewModel.currentUser?.name ?? "User")
                    .font(.title2)
                    .fontWeight(.bold)
                
                // User email
                Text(userViewModel.currentUser?.email ?? "")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                // Stats cards
                HStack(spacing: 10) {
                    // Total orders
                    StatCard(title: "Orders", value: "\(userViewModel.userOrders.count)", icon: "bag.fill")
                    
                    // Total spent
                    StatCard(
                        title: "Spent",
                        value: String(format: "$%.2f", userViewModel.totalSpent),
                        icon: "creditcard.fill"
                    )
                    
                    // Favorite drink
                    StatCard(
                        title: "Favorite",
                        value: userViewModel.favoriteOrder ?? "None",
                        icon: "heart.fill"
                    )
                }
                .padding(.top, 5)
            }
            .padding()
            .background(Color.white)
            
            // Tabs
            Picker("View", selection: $selectedTab) {
                Text("Orders").tag(0)
                Text("Account").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            .padding(.top, 5)
            
            // Tab content
            TabView(selection: $selectedTab) {
                // Orders Tab
                OrderHistoryListView(viewModel: userViewModel)
                    .tag(0)
                
                // Account Tab
                AccountSettingsView(
                    userViewModel: userViewModel,
                    authViewModel: authViewModel,
                    showingSignOutAlert: $showingSignOutAlert
                )
                .tag(1)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .animation(.easeInOut, value: selectedTab)
        }
        .alert(isPresented: $showingSignOutAlert) {
            Alert(
                title: Text("Sign Out"),
                message: Text("Are you sure you want to sign out?"),
                primaryButton: .destructive(Text("Sign Out")) {
                    authViewModel.signOut { _ in
                        // Navigation will be handled by ContentView
                    }
                },
                secondaryButton: .cancel()
            )
        }
        .onAppear {
            if authViewModel.isAuthenticated {
                userViewModel.fetchCurrentUser()
                userViewModel.fetchUserOrders()
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Stat card component
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(AppColors.primary)
            
            Text(value)
                .font(.headline)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(AppColors.secondaryBackground)
        .cornerRadius(10)
    }
}

// Account settings view
struct AccountSettingsView: View {
    let userViewModel: UserViewModel
    let authViewModel: AuthenticationViewModel
    @Binding var showingSignOutAlert: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Account settings section
                VStack(alignment: .leading, spacing: 5) {
                    Text("Account Settings")
                        .font(.headline)
                        .padding(.bottom, 5)
                    
                    NavigationLink(destination: Text("Edit Profile")) {
                        SettingsRow(title: "Edit Profile", icon: "person.fill")
                    }
                    
                    NavigationLink(destination: Text("Notifications Settings")) {
                        SettingsRow(title: "Notifications", icon: "bell.fill")
                    }
                    
                    NavigationLink(destination: Text("Payment Methods")) {
                        SettingsRow(title: "Payment Methods", icon: "creditcard.fill")
                    }
                }
                .padding()
                .background(AppColors.secondaryBackground)
                .cornerRadius(10)
                
                // Support section
                VStack(alignment: .leading, spacing: 5) {
                    Text("Support")
                        .font(.headline)
                        .padding(.bottom, 5)
                    
                    NavigationLink(destination: Text("Help Center")) {
                        SettingsRow(title: "Help Center", icon: "questionmark.circle.fill")
                    }
                    
                    NavigationLink(destination: Text("About QuickSip")) {
                        SettingsRow(title: "About QuickSip", icon: "info.circle.fill")
                    }
                }
                .padding()
                .background(AppColors.secondaryBackground)
                .cornerRadius(10)
                
                // Sign out button
                Button(action: {
                    showingSignOutAlert = true
                }) {
                    Text("Sign Out")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(10)
                }
                .padding(.top, 20)
            }
            .padding()
        }
    }
}

// Settings row component
struct SettingsRow: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 24, height: 24)
                .foregroundColor(AppColors.primary)
            
            Text(title)
                .font(.subheadline)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}

#Preview {
    NavigationStack {
        ProfileView()
    }
} 