//
//  OrderFormView.swift
//  QuickSip
//
//  Created by Seun Adekunle on 4/20/25.
//

import SwiftUI
import Firebase

struct OrderFormView: View {
    // Dependencies
    @EnvironmentObject private var authViewModel: AuthenticationViewModel
    @StateObject private var orderViewModel = OrderViewModel()
    @Environment(\.presentationMode) private var presentationMode
    
    // Input from previous screen
    let selectedDrink: DrinkType
    
    // Form Fields
    @State private var name: String = ""
    @State private var location: String = ""
    @State private var additionalRequests: String = ""
    @State private var selectedPaymentMethod: PaymentMethod = .applePay
    @State private var selectedLocation: Location = .leavey
    
    // Form State
    @State private var showingErrors = false
    @State private var showingOrderConfirmation = false
    @State private var showSuccessAnimation = false
    @FocusState private var focusedField: FormField?
    
    // Helpers for form handling and validation
    enum FormField {
        case name, additionalRequests
    }
    
    enum PaymentMethod: String, Identifiable {
        case applePay = "Apple Pay"
        
        var id: String { self.rawValue }
        
        var iconName: String {
            return "applepay"
        }
    }
    
    enum Location: String, CaseIterable, Identifiable {
        case leavey = "Leavey Library"
        case doheny = "Doheny Library"
        
        var id: String { self.rawValue }
        
        var iconName: String {
            switch self {
            case .leavey:
                return "books.vertical"
            case .doheny:
                return "building.columns"
            }
        }
    }
    
    // Validation logic
    var formIsValid: Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmedName.isEmpty && trimmedName.count >= 2
    }
    
    // Form validation errors
    var nameError: String? {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedName.isEmpty && showingErrors {
            return "Name is required"
        } else if trimmedName.count < 2 && showingErrors {
            return "Name must be at least 2 characters"
        }
        return nil
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 25) {
                // Header
                Text("Complete Your Order")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.primary)
                    .padding(.top)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                // Selected Drink Display
                HStack(spacing: 15) {
                    Image(systemName: selectedDrink.iconName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25, height: 25)
                        .foregroundColor(.white)
                    
                    Text(selectedDrink.rawValue)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        // Dismiss this view to go back to drink selection
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Change")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
                .padding()
                .background(AppColors.primary)
                .cornerRadius(12)
                
                // Form Fields
                VStack(alignment: .leading, spacing: 20) {
                    // Name Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Name")
                            .font(.headline)
                            .foregroundColor(AppColors.textPrimary)
                        
                        TextField("Your name", text: $name)
                            .padding()
                            .background(AppColors.secondaryBackground)
                            .cornerRadius(10)
                            .focused($focusedField, equals: .name)
                            .submitLabel(.next)
                            .onSubmit {
                                // Move to additional requests field when user hits "next" on keyboard
                                focusedField = .additionalRequests
                            }
                            .onChange(of: name) { _ in
                                if !name.isEmpty && showingErrors {
                                    showingErrors = false
                                }
                            }
                        
                        if let error = nameError {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.leading, 4)
                                .accessibilityLabel("Error: \(error)")
                        }
                    }
                    
                    // Location Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Location (University of Southern California)")
                            .font(.headline)
                            .foregroundColor(AppColors.textPrimary)
                        
                        ForEach(Location.allCases) { location in
                            Button(action: {
                                selectedLocation = location
                                
                                // Add haptic feedback
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()
                            }) {
                                HStack {
                                    Image(systemName: location.iconName)
                                        .foregroundColor(selectedLocation == location ? .white : AppColors.primary)
                                    
                                    Text(location.rawValue)
                                        .fontWeight(selectedLocation == location ? .semibold : .regular)
                                        .foregroundColor(selectedLocation == location ? .white : AppColors.textPrimary)
                                    
                                    Spacer()
                                    
                                    if selectedLocation == location {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.white)
                                    }
                                }
                                .padding()
                                .background(selectedLocation == location ? AppColors.primary : AppColors.secondaryBackground)
                                .cornerRadius(10)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .accessibilityAddTraits(selectedLocation == location ? [.isButton, .isSelected] : [.isButton])
                            .accessibilityHint("Select \(location.rawValue) as delivery location")
                        }
                    }
                    
                    // Payment Method Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Payment Method")
                            .font(.headline)
                            .foregroundColor(AppColors.textPrimary)
                        
                        // Apple Pay Button
                        HStack {
                            Image(systemName: "applepay")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 25)
                                .foregroundColor(.white)
                            
                            Text("Apple Pay")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(AppColors.primary)
                        .cornerRadius(10)
                        .accessibilityAddTraits([.isButton, .isSelected])
                        .accessibilityLabel("Apple Pay payment method selected")
                    }
                    
                    // Additional Requests Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Additional Requests (Optional)")
                            .font(.headline)
                            .foregroundColor(AppColors.textPrimary)
                        
                        TextEditor(text: $additionalRequests)
                            .frame(height: 100)
                            .padding(10)
                            .background(AppColors.secondaryBackground)
                            .cornerRadius(10)
                            .focused($focusedField, equals: .additionalRequests)
                            .onSubmit {
                                // Submit the form if it's valid
                                if formIsValid {
                                    submitOrder()
                                }
                            }
                    }
                }
                
                // Submit Button
                Button(action: {
                    submitOrder()
                }) {
                    HStack {
                        if showSuccessAnimation {
                            // Success checkmark
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.trailing, 5)
                            
                            Text("Order Submitted!")
                                .font(.headline)
                                .foregroundColor(.white)
                        } else {
                            Text("Submit Order")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            if orderViewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .padding(.leading, 5)
                            }
                        }
                    }
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(
                        Group {
                            if showSuccessAnimation {
                                Color.green
                            } else if formIsValid {
                                AppColors.primary
                            } else {
                                AppColors.primary.opacity(0.5)
                            }
                        }
                    )
                    .cornerRadius(15)
                }
                .disabled(!formIsValid || orderViewModel.isLoading || showSuccessAnimation)
                .padding(.top, 10)
                .accessibilityHint(formIsValid ? "Submit your order" : "Please fill out all required fields")
                
                // Error Message
                if let errorMessage = orderViewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .padding()
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.red.opacity(0.1))
                        )
                        .padding(.vertical, 5)
                }
                
                // Form validation error (shown when trying to submit with invalid data)
                if showingErrors && !formIsValid {
                    Text("Please fill out all required fields")
                        .foregroundColor(.orange)
                        .font(.footnote)
                        .padding()
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.orange.opacity(0.1))
                        )
                        .padding(.vertical, 5)
                }
                
                Spacer(minLength: 20)
            }
            .padding()
        }
        .navigationTitle("Order Details")
        .navigationBarTitleDisplayMode(.inline)
        .onTapGesture {
            // Dismiss keyboard on tap outside of fields
            focusedField = nil
        }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button("Done") {
                    focusedField = nil
                }
            }
        }
        .onAppear {
            // Set up notification observer to dismiss view when requested
            NotificationCenter.default.addObserver(
                forName: Notification.Name("DismissToRootView"),
                object: nil,
                queue: .main) { notification in
                    // Check if the notification was from the OrderConfirmation view
                    let shouldForce = (notification.userInfo?["force"] as? Bool) ?? false
                    let source = (notification.userInfo?["source"] as? String) ?? ""
                    
                    // If forced or from OrderConfirmation, dismiss this view
                    if shouldForce || source == "OrderConfirmation" {
                        // Dismiss this view when the notification is received
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
        }
        .onDisappear {
            // Remove notification observer
            NotificationCenter.default.removeObserver(
                self,
                name: Notification.Name("DismissToRootView"),
                object: nil
            )
        }
        // Navigation to confirmation screen
        NavigationLink(
            destination: orderViewModel.order.map { OrderConfirmationView(order: $0) },
            isActive: $showingOrderConfirmation
        ) {
            EmptyView()
        }
    }
    
    // Submit order function
    private func submitOrder() {
        // Validate form first
        if !formIsValid {
            showingErrors = true
            return
        }
        
        // Get the current user ID from AuthViewModel
        guard let userId = authViewModel.currentUserId else {
            orderViewModel.errorMessage = "You must be logged in to place an order"
            return
        }
        
        // Create and submit order
        orderViewModel.createOrder(
            userId: userId,
            drinkType: selectedDrink.rawValue,
            location: selectedLocation.rawValue,
            paymentMethod: selectedPaymentMethod.rawValue,
            additionalRequests: additionalRequests.isEmpty ? nil : additionalRequests
        )
        
        // Navigate to confirmation screen when order is created successfully
        // Adding a success animation before navigation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if orderViewModel.order != nil && orderViewModel.errorMessage == nil {
                // Show success animation
                withAnimation(.spring()) {
                    showSuccessAnimation = true
                }
                
                // Add haptic feedback for success
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                
                // Delay navigation to show the animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    withAnimation {
                        showingOrderConfirmation = true
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        OrderFormView(selectedDrink: .icedCoffee)
            .environmentObject(AuthenticationViewModel())
    }
} 