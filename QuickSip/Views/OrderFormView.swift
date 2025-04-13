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
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // Form validation errors
    var nameError: String? {
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && showingErrors {
            return "Name is required"
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
                        // Go back to drink selection
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
                        Text("Location")
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
                    }
                }
                
                // Submit Button
                Button(action: {
                    submitOrder()
                }) {
                    HStack {
                        Text("Submit Order")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        if orderViewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .padding(.leading, 5)
                        }
                    }
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(formIsValid ? AppColors.primary : AppColors.primary.opacity(0.5))
                    .cornerRadius(15)
                }
                .disabled(!formIsValid || orderViewModel.isLoading)
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
        .onChange(of: focusedField) { newValue in
            // Handle keyboard next button
            if newValue == .name {
                // Focus on additional requests next since location is now a picker
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    focusedField = .additionalRequests
                }
            }
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
        // This will happen automatically when the orderViewModel.order is set
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if orderViewModel.order != nil && orderViewModel.errorMessage == nil {
                showingOrderConfirmation = true
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