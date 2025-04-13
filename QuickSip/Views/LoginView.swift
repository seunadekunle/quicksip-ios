//
//  LoginView.swift
//  QuickSip
//
//  Created by Seun Adekunle on 4/12/25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel
    
    var body: some View {
        ZStack {
            // Matcha-inspired background
            LinearGradient(
                gradient: Gradient(colors: [AppColors.background, AppColors.matchaLight]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                Spacer()
                
                // Matcha themed logo styling
                VStack(spacing: 15) {
                    ZStack {
                        Circle()
                            .fill(AppColors.matchaLight)
                            .frame(width: 100, height: 100)
                            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                        
                        Image(systemName: "cup.and.saucer.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 60)
                            .foregroundColor(AppColors.primary)
                            .accessibilityLabel("QuickSip App Logo")
                    }
                    
                    Text("QuickSip")
                        .font(.system(size: 32, weight: .heavy))
                        .foregroundColor(AppColors.matchaDark)
                }
                .padding(.bottom, 30)
                
                // Error Message
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 5)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color.red.opacity(0.1))
                        )
                }
                
                // Google Sign In Button with matcha styling
                Button(action: {
                    viewModel.signInWithGoogle { success in
                        if !success {
                            // Error is handled by the ViewModel
                        }
                    }
                }) {
                    HStack(spacing: 15) {
                        Image(systemName: "g.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.primary)
                        
                        Text("Sign in with Google")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppColors.textPrimary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                    )
                    .padding(.horizontal, 30)
                }
                .disabled(viewModel.isLoading)
                .padding(.bottom, 30)
                
                // Added: Matcha themed decoration
                HStack(spacing: 25) {
                    matchaDecoration
                    matchaDecoration
                    matchaDecoration
                }
                .padding(.bottom, 40)
                
                Spacer()
                
                // Matcha quote
                Text("\"Matcha: calm energy in every sip\"")
                    .font(.system(size: 18, weight: .medium, design: .serif))
                    .italic()
                    .foregroundColor(AppColors.matchaDark)
                    .padding(.bottom, 20)
            }
            .padding()
            
            // Loading overlay
            if viewModel.isLoading {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    ProgressView()
                        .scaleEffect(1.5)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    
                    Text("Preparing...")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.top, 10)
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.black.opacity(0.7))
                )
            }
        }
    }
    
    // Matcha leaf decoration
    private var matchaDecoration: some View {
        Image(systemName: "leaf.fill")
            .font(.system(size: 14))
            .foregroundColor(AppColors.primary)
            .padding(8)
            .background(
                Circle()
                    .fill(AppColors.matchaLight)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
            )
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthenticationViewModel())
} 
