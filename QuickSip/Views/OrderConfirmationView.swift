//
//  OrderConfirmationView.swift
//  QuickSip
//
//  Created by Seun Adekunle on 4/20/25.
//

import SwiftUI

struct OrderConfirmationView: View {
    // Dependencies
    @EnvironmentObject private var authViewModel: AuthenticationViewModel
    
    // Properties
    let order: Order
    @State private var showHome = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Success check mark
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .foregroundColor(AppColors.primary)
                    .padding(.top, 40)
                
                // Confirmation message
                Text("Your drink is on the way!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text("Order #\(order.id.prefix(6).uppercased())")
                    .font(.headline)
                    .foregroundColor(AppColors.textSecondary)
                
                // Order details card
                VStack(alignment: .leading, spacing: 15) {
                    // Order details header
                    Text("Order Details")
                        .font(.headline)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Divider()
                    
                    // Drink type
                    HStack {
                        Text("Drink")
                            .foregroundColor(AppColors.textSecondary)
                        Spacer()
                        Text(order.drinkType)
                            .fontWeight(.medium)
                            .foregroundColor(AppColors.textPrimary)
                    }
                    
                    // Location
                    HStack {
                        Text("Location")
                            .foregroundColor(AppColors.textSecondary)
                        Spacer()
                        Text(order.location)
                            .fontWeight(.medium)
                            .foregroundColor(AppColors.textPrimary)
                    }
                    
                    // Payment method
                    HStack {
                        Text("Payment")
                            .foregroundColor(AppColors.textSecondary)
                        Spacer()
                        Text(order.paymentMethod)
                            .fontWeight(.medium)
                            .foregroundColor(AppColors.textPrimary)
                    }
                    
                    // Order status
                    HStack {
                        Text("Status")
                            .foregroundColor(AppColors.textSecondary)
                        Spacer()
                        Text(order.status.capitalized)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }
                    
                    // Additional requests (if any)
                    if let additionalRequests = order.additionalRequests, !additionalRequests.isEmpty {
                        Divider()
                        
                        Text("Additional Requests:")
                            .foregroundColor(AppColors.textSecondary)
                        
                        Text(additionalRequests)
                            .foregroundColor(AppColors.textPrimary)
                            .padding(.leading, 5)
                    }
                }
                .padding()
                .background(AppColors.secondaryBackground)
                .cornerRadius(15)
                .padding(.horizontal)
                
                // Estimated time
                VStack {
                    Text("Estimated Time")
                        .font(.headline)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("10-15 minutes")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.primary)
                }
                .padding(.vertical)
                
                // Return to Home button
                Button(action: {
                    showHome = true
                }) {
                    Text("Return to Home")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                        .background(AppColors.primary)
                        .cornerRadius(15)
                }
                .padding(.horizontal)
                .padding(.top, 20)
                .padding(.bottom, 40)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Order Confirmation")
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
        }
        .background(
            NavigationLink(destination: HomeView(), isActive: $showHome) {
                EmptyView()
            }
        )
    }
}

#Preview {
    let sampleOrder = Order(
        userId: "user123",
        drinkType: "Iced Matcha",
        location: "Leavey Library",
        paymentMethod: "Apple Pay",
        additionalRequests: "Extra ice, please."
    )
    
    return NavigationStack {
        OrderConfirmationView(order: sampleOrder)
            .environmentObject(AuthenticationViewModel())
    }
} 