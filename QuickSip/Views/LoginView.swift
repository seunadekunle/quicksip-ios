//
//  LoginView.swift
//  QuickSip
//
//  Created by Seun Adekunle on 4/12/25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel
    @State private var showHomeView = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Spacer()
                // Logo
                Image(systemName: "cup.and.saucer.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .foregroundColor(AppColors.primary)
                    .accessibilityLabel("QuickSip App Logo")
                
                Text("QuickSip")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(AppColors.primary)
                
                Text("Welcome to QuickSip")
                    .font(.title3)
                    .fontWeight(.medium)
                    .padding(.top, 10) 
                
                // Error Message
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)
                }
                
                // Google Sign In Button
                Button(action: {
                    viewModel.signInWithGoogle { success in
                        if !success {
                            // Error is handled by the ViewModel
                        }
                    }
                }) {
                    HStack {
                        Image(systemName: "g.circle.fill") // Using SFSymbol as placeholder
                            .foregroundColor(.primary)
                        
                        Text("Sign in with Google")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.white)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    )
                    .padding(.horizontal)
                }
                .disabled(viewModel.isLoading)
                .padding(.bottom, 50)
                
                Spacer()
                
                // Navigation link that activates when authentication is successful
                NavigationLink(destination: HomeView(), isActive: $viewModel.navigateToHome) {
                    EmptyView()
                }
            }
            .padding()
            .background(AppColors.background)
            .edgesIgnoringSafeArea(.all)
            .overlay(
                ZStack {
                    if viewModel.isLoading {
                        Color.black.opacity(0.4)
                            .edgesIgnoringSafeArea(.all)
                        
                        VStack {
                            ProgressView()
                                .scaleEffect(1.5)
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            
                            Text("Loading...")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.top, 10)
                        }
                        .padding(20)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(10)
                    }
                }
            )
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthenticationViewModel())
} 
