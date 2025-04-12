//
//  HomeView.swift
//  QuickSip
//
//  Created by Seun Adekunle on 4/12/25.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack(spacing: 30) {
            // Logo and Welcome
            VStack(spacing: 20) {
                Image(systemName: "cup.and.saucer.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .foregroundColor(AppColors.primary)
                    .accessibilityLabel("QuickSip App Logo")
                
                Text("QuickSip")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(AppColors.primary)
                    .accessibilityAddTraits(.isHeader)
                
                Text("Your drinks, delivered fast")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.bottom, 20)
                    .accessibilityLabel("Your drinks, delivered fast")
            }
            .padding(.top, 50)
            
            Spacer()
            
            // Features Section
            HStack(spacing: 30) {
                FeatureItem(icon: "clock.fill", title: "Fast Delivery", description: "Get your drinks in under 15 minutes")
                
                FeatureItem(icon: "cup.and.saucer.fill", title: "Quality Drinks", description: "Fresh ingredients every time")
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Order Now Button
            NavigationLink(destination: DrinkSelectionView()) {
                Text("Order Now")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 250, height: 60)
                    .background(AppColors.primary)
                    .cornerRadius(15)
                    .shadow(radius: 5)
            }
            .padding(.bottom, 50)
            .accessibilityLabel("Order Now")
            .accessibilityHint("Tap to select your drink")
            .accessibilityAddTraits(.isButton)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Home")
                    .font(.headline)
                    .foregroundColor(AppColors.primary)
            }
        }
    }
}

// Feature Item Component
struct FeatureItem: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Image(systemName: icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30)
                .foregroundColor(AppColors.primary)
            
            Text(title)
                .font(.headline)
                .foregroundColor(AppColors.textPrimary)
            
            Text(description)
                .font(.caption)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppColors.secondaryBackground)
        .cornerRadius(10)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
} 
