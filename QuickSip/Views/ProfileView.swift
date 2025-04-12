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
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // User info section
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
                }
                .padding(.vertical, 30)
                
                // Orders count
                HStack(spacing: 30) {
                    VStack {
                        Text("\(userViewModel.userOrders.count)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.primary)
                        
                        Text("Orders")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    VStack {
                        Text(userViewModel.userOrders.filter { $0.status == Order.Status.delivered.rawValue }.count.description)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.primary)
                        
                        Text("Completed")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .background(AppColors.secondaryBackground)
                .cornerRadius(10)
                
                Divider()
                    .padding(.vertical, 20)
                
                // Settings section
                VStack(spacing: 15) {
                    // Order History
                    NavigationLink(destination: Text("Order History")) {
                        HStack {
                            Image(systemName: "list.bullet")
                                .foregroundColor(AppColors.primary)
                                .frame(width: 30)
                            
                            Text("Order History")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(AppColors.secondaryBackground)
                    .cornerRadius(10)
                    
                    // Payment Methods
                    NavigationLink(destination: Text("Payment Methods")) {
                        HStack {
                            Image(systemName: "creditcard")
                                .foregroundColor(AppColors.primary)
                                .frame(width: 30)
                            
                            Text("Payment Methods")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(AppColors.secondaryBackground)
                    .cornerRadius(10)
                    
                    // Notifications
                    NavigationLink(destination: Text("Notifications")) {
                        HStack {
                            Image(systemName: "bell")
                                .foregroundColor(AppColors.primary)
                                .frame(width: 30)
                            
                            Text("Notifications")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(AppColors.secondaryBackground)
                    .cornerRadius(10)
                }
                
                Spacer()
                
                // Sign Out Button
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
                .padding(.bottom, 20)
            }
            .padding()
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
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
        }
    }
}

#Preview {
    ProfileView()
} 