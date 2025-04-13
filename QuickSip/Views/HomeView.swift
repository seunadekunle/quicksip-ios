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
    @State private var showingDrinkSelection = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                
                // Search bar with matcha-themed styling
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(AppColors.matchaDark)
                    
                    TextField("Search for matcha...", text: $searchText)
                        .foregroundColor(AppColors.textPrimary)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(AppColors.secondaryBackground)
                        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
                )
                .padding(.horizontal)
                .padding(.top, 15)
                
                // Featured Drinks - Matcha section
                VStack(alignment: .leading, spacing: 15) {
                    Text("Today's Specials")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.matchaDark)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            FeaturedDrinkCard(
                                name: "Ceremonial Matcha",
                                price: "$5.99",
                                imageName: "leaf.fill"
                            )
                            
                            FeaturedDrinkCard(
                                name: "Matcha Latte",
                                price: "$4.99",
                                imageName: "cup.and.saucer.fill"
                            )
                            
                            FeaturedDrinkCard(
                                name: "Iced Matcha",
                                price: "$4.49",
                                imageName: "snowflake"
                            )
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical, 10)
                
                // Top Vendors Section
                VStack(alignment: .leading, spacing: 15) {
                    Text("Our Locations")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.matchaDark)
                        .padding(.horizontal)
                    
                    ForEach(Vendor.samples) { vendor in
                        VendorCardMatchaStyle(vendor: vendor, showingDrinkSelection: $showingDrinkSelection)
                    }
                }
                
                // Features Section with matcha-themed content
                Text("Why Choose QuickSip?")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.matchaDark)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                HStack(spacing: 15) {
                    MatchaFeatureItem(icon: "clock.fill", title: "Fast Delivery", description: "Get your matcha in under 15 minutes")
                    
                    MatchaFeatureItem(icon: "leaf.fill", title: "Premium Quality", description: "Authentic Japanese matcha powder")
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
        }
        .background(
            AppColors.background
                .ignoresSafeArea()
                .overlay(
                    // Matcha leaf pattern overlay
                    Image(systemName: "leaf.fill")
                        .resizable(resizingMode: .tile)
                        .foregroundColor(AppColors.matchaLight.opacity(0.15))
                        .ignoresSafeArea()
                )
        )
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingDrinkSelection) {
            NavigationView {
                DrinkSelectionView()
            }
        }
    }
}

// Featured drink card for matcha
struct FeaturedDrinkCard: View {
    let name: String
    let price: String
    let imageName: String
    
    var body: some View {
        VStack(alignment: .center) {
            Image(systemName: imageName)
                .font(.system(size: 40))
                .foregroundColor(AppColors.primary)
                .padding()
                .background(
                    Circle()
                        .fill(AppColors.matchaLight)
                )
                .padding(.bottom, 5)
            
            Text(name)
                .font(.headline)
                .foregroundColor(AppColors.textPrimary)
            
            Text(price)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.primary)
        }
        .frame(width: 140, height: 180)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 2)
        )
    }
}

// Matcha themed Vendor Card
struct VendorCardMatchaStyle: View {
    let vendor: Vendor
    @Binding var showingDrinkSelection: Bool
    
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
        Button(action: {
            showingDrinkSelection = true
        }) {
            HStack(spacing: 15) {
                // Vendor Image
                Image(systemName: vendor.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                    .foregroundColor(AppColors.primary)
                    .padding()
                    .background(
                        Circle()
                            .fill(AppColors.matchaLight)
                    )
                
                // Vendor Details
                VStack(alignment: .leading, spacing: 5) {
                    Text(vendor.name)
                        .font(.headline)
                        .foregroundColor(AppColors.matchaDark)
                    
                    Text(vendor.description)
                        .font(.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                        .lineLimit(1)
                    
                    // Rating
                    HStack {
                        ForEach(0..<5, id: \.self) { index in
                            Image(systemName: starImages[index])
                                .foregroundColor(AppColors.matchaLight)
                                .font(.system(size: 12))
                        }
                        
                        Text(String(format: "%.1f", vendor.rating))
                            .font(.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                
                Spacer()
                
                // Arrow indicator
                Image(systemName: "chevron.right")
                    .foregroundColor(AppColors.primary)
                    .font(.system(size: 14, weight: .semibold))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 2)
            )
        }
        .padding(.horizontal)
        .buttonStyle(PlainButtonStyle())
    }
}

// Matcha themed Feature Item
struct MatchaFeatureItem: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 15) {
            Image(systemName: icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30)
                .foregroundColor(AppColors.primary)
                .padding(12)
                .background(
                    Circle()
                        .fill(AppColors.matchaLight)
                )
            
            Text(title)
                .font(.headline)
                .foregroundColor(AppColors.matchaDark)
            
            Text(description)
                .font(.caption)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
}
