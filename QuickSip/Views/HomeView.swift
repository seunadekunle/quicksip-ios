//
//  HomeView.swift
//  QuickSip
//
//  Created by Seun Adekunle on 4/12/25.
//

import SwiftUI

// Vendor model
struct Vendor: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let rating: Double
    let imageName: String
    
    // Static sample data
    static let samples = [
        Vendor(name: "Campus Coffee", description: "Premium coffee from around the world", rating: 4.7, imageName: "cup.and.saucer.fill"),
        Vendor(name: "Matcha Haven", description: "Authentic matcha from Japan", rating: 4.5, imageName: "leaf.fill"),
        Vendor(name: "Brew Express", description: "Fast coffee delivery service", rating: 4.2, imageName: "speedometer")
    ]
}

struct HomeView: View {
    @State private var searchText = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Logo and Welcome
                VStack(spacing: 20) {
                    Image(systemName: "cup.and.saucer.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .foregroundColor(AppColors.primary)
                        .accessibilityLabel("QuickSip App Logo")
                    
                    Text("QuickSip")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(AppColors.primary)
                        .accessibilityAddTraits(.isHeader)
                    
                    Text("Your drinks, delivered fast")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                        .padding(.bottom, 10)
                        .accessibilityLabel("Your drinks, delivered fast")
                }
                .padding(.top, 20)
                
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(AppColors.textSecondary)
                    
                    TextField("Search for vendors...", text: $searchText)
                        .foregroundColor(AppColors.textPrimary)
                }
                .padding()
                .background(AppColors.secondaryBackground)
                .cornerRadius(15)
                .padding(.horizontal)
                
                // Top Vendors Section
                VStack(alignment: .leading, spacing: 15) {
                    Text("Top Vendors")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.textPrimary)
                        .padding(.horizontal)
                    
                    ForEach(Vendor.samples) { vendor in
                        VendorCard(vendor: vendor)
                    }
                }
                
                // Features Section
                Text("Why Choose QuickSip?")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                HStack(spacing: 15) {
                    FeatureItem(icon: "clock.fill", title: "Fast Delivery", description: "Get your drinks in under 15 minutes")
                    
                    FeatureItem(icon: "cup.and.saucer.fill", title: "Quality Drinks", description: "Fresh ingredients every time")
                }
                .padding(.horizontal)
                
                // Order Now Button
                NavigationLink(destination: DrinkSelectionView()) {
                    Text("Order Now")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(AppColors.primary)
                        .cornerRadius(15)
                        .padding(.horizontal)
                }
                .padding(.top, 20)
                .padding(.bottom, 30)
                .accessibilityLabel("Order Now")
                .accessibilityHint("Tap to select your drink")
                .accessibilityAddTraits(.isButton)
            }
        }
        .background(AppColors.background)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Vendor Card Component
struct VendorCard: View {
    let vendor: Vendor
    
    // Precomputed star images to simplify view generation
    private var starImages: [String] {
        (1...5).map { position in
            if Double(position) <= vendor.rating {
                return "star.fill"
            } else if Double(position-1) < vendor.rating && Double(position) > vendor.rating {
                return "star.leadinghalf.fill"
            } else {
                return "star"
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 15) {
            // Vendor Image
            Image(systemName: vendor.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                .foregroundColor(AppColors.primary)
                .padding()
                .background(AppColors.secondaryBackground)
                .cornerRadius(10)
            
            // Vendor Details
            VStack(alignment: .leading, spacing: 5) {
                Text(vendor.name)
                    .font(.headline)
                    .foregroundColor(AppColors.textPrimary)
                
                Text(vendor.description)
                    .font(.subheadline)
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(1)
                
                // Rating - simplified to reduce complexity
                HStack {
                    ForEach(0..<5, id: \.self) { index in
                        Image(systemName: starImages[index])
                            .foregroundColor(.yellow)
                            .font(.system(size: 12))
                    }
                    
                    Text(String(format: "%.1f", vendor.rating))
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            
            Spacer()
            
            // Order Button
            NavigationLink(destination: DrinkSelectionView()) {
                Text("Order")
                    .font(.callout)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(AppColors.primary)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
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