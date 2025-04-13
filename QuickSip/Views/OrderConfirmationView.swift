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
    @Environment(\.presentationMode) private var presentationMode
    
    // For dismissing to root view
    @Environment(\.dismiss) private var dismiss
    
    // StatusUpdateService for real-time updates
    @StateObject private var statusService = StatusUpdateService.shared
    
    // Properties
    let order: Order
    
    // UI state
    @State private var rootPresentationMode: Binding<PresentationMode>? = nil
    @State private var hasDismissed = false
    @State private var showingConnectionAlert = false
    
    // Computed properties for UI
    private var displayStatus: String {
        // Use the real-time status if available, otherwise fall back to the initial order status
        return statusService.currentOrderStatus?.capitalized ?? order.status.capitalized
    }
    
    private var statusColor: Color {
        switch displayStatus.lowercased() {
        case "placed":
            return .orange
        case "in progress":
            return .blue
        case "delivered":
            return .green
        case "cancelled":
            return .red
        default:
            return .gray
        }
    }
    
    private var lastUpdatedText: String? {
        guard let lastUpdated = statusService.lastUpdated else { return nil }
        
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return "Updated \(formatter.localizedString(for: lastUpdated, relativeTo: Date()))"
    }
    
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
                
                // Real-time status indicator
                if !statusService.isConnected {
                    HStack {
                        Image(systemName: "wifi.slash")
                        Text("Offline - Status updates unavailable")
                            .font(.footnote)
                    }
                    .foregroundColor(.red)
                    .padding(.vertical, 5)
                    .onTapGesture {
                        showingConnectionAlert = true
                    }
                }
                
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
                        Text("Location (Universtiy of Southern California)")
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
                    
                    // Order status with real-time updates
                    HStack {
                        Text("Status")
                            .foregroundColor(AppColors.textSecondary)
                        Spacer()
                        Text(displayStatus)
                            .fontWeight(.semibold)
                            .foregroundColor(statusColor)
                            .animation(.easeInOut, value: displayStatus)
                    }
                    
                    // Show last update time if available
                    if let lastUpdatedText = lastUpdatedText {
                        Text(lastUpdatedText)
                            .font(.caption)
                            .foregroundColor(AppColors.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .trailing)
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
                
                // Estimated time with dynamic calculation based on status
                VStack {
                    Text("Estimated Time")
                        .font(.headline)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text(estimatedTimeText)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.primary)
                        .animation(.easeInOut, value: displayStatus)
                }
                .padding(.vertical)
                
                // Return to Home button
                Button(action: {
                    // Only try to dismiss once
                    if !hasDismissed {
                        hasDismissed = true
                        // Clean up listeners before dismissing
                        statusService.stopListeningForOrderUpdates(orderId: order.id)
                        // Dismiss all the way back to root view
                        dismissToRoot()
                    }
                }) {
                    Text("Return to Home")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                        .background(AppColors.primary)
                        .cornerRadius(15)
                }
                .buttonStyle(PlainButtonStyle()) // Use plain button style
                .padding(.horizontal)
                .padding(.top, 20)
                .padding(.bottom, 40)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Order Confirmation")
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $showingConnectionAlert) {
                Alert(
                    title: Text("Connection Issue"),
                    message: Text("Unable to get real-time status updates. The last known status is shown."),
                    primaryButton: .default(Text("Retry")) {
                        statusService.startListeningForOrderUpdates(orderId: order.id)
                    },
                    secondaryButton: .cancel()
                )
            }
            .onAppear {
                // Start listening for status updates when the view appears
                statusService.startListeningForOrderUpdates(orderId: order.id)
            }
            .onDisappear {
                // Stop listening when the view disappears
                statusService.stopListeningForOrderUpdates(orderId: order.id)
            }
        }
    }
    
    // Dynamic estimated time based on status
    private var estimatedTimeText: String {
        switch displayStatus.lowercased() {
        case "placed":
            return "10-15 minutes"
        case "in progress":
            return "5-7 minutes"
        case "delivered":
            return "Ready for pickup!"
        case "cancelled":
            return "Order cancelled"
        default:
            return "Processing..."
        }
    }
    
    // Function to dismiss all the way back to the home view
    private func dismissToRoot() {
        // First dismiss the current view
        dismiss()
        
        // Add a small delay to ensure the current view starts dismissing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Post a notification to dismiss all presentations with context info
            NotificationCenter.default.post(
                name: Notification.Name("DismissToRootView"),
                object: nil,
                userInfo: ["source": "OrderConfirmation", "force": true]
            )
            
            // Additional fallback using a longer delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // Try to dismiss presentation mode as well
                self.presentationMode.wrappedValue.dismiss()
            }
        }
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