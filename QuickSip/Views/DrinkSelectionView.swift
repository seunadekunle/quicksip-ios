//
//  DrinkSelectionView.swift
//  QuickSip
//
//  Created by Seun Adekunle on 4/12/25.
//

import SwiftUI
import UIKit // Added for UIImpactFeedbackGenerator

// Drink Type Enum
enum DrinkType: String, CaseIterable, Identifiable {
    case icedCoffee = "Iced Coffee"
    case icedMatcha = "Iced Matcha"
    
    var id: String { self.rawValue }
    
    var iconName: String {
        switch self {
        case .icedCoffee:
            return "cup.and.saucer.fill"
        case .icedMatcha:
            return "leaf.fill"
        }
    }
    
    var description: String {
        switch self {
        case .icedCoffee:
            return "Classic cold brew with a smooth finish"
        case .icedMatcha:
            return "Premium matcha with a hint of sweetness"
        }
    }
}

// Full DrinkSelectionView implementation
struct DrinkSelectionView: View {
    @State private var selectedDrink: DrinkType?
    @State private var showingOrderForm = false
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        VStack(spacing: 25) {
            Text("Select Your Drink")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(AppColors.primary)
                .padding(.top)
                .accessibilityAddTraits(.isHeader)
            
            Text("Choose from our signature drinks")
                .font(.subheadline)
                .foregroundColor(AppColors.textSecondary)
                .padding(.bottom)
            
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(DrinkType.allCases) { drink in
                        DrinkOptionCard(
                            drink: drink,
                            isSelected: selectedDrink == drink,
                            action: {
                                selectedDrink = drink
                                // Add haptic feedback
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer()
            
            // Order Now Button
            Button(action: {
                showingOrderForm = true
            }) {
                Text("Continue to Order")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(selectedDrink != nil ? AppColors.primary : AppColors.primary.opacity(0.5))
                    .cornerRadius(15)
                    .padding(.horizontal)
            }
            .disabled(selectedDrink == nil)
            .padding(.bottom, 30)
            .accessibilityLabel("Continue to Order")
            .accessibilityHint(selectedDrink == nil ? "Select a drink first" : "Tap to continue with your \(selectedDrink?.rawValue ?? "") order")
            
            NavigationLink(
                destination: selectedDrink.map { OrderFormView(selectedDrink: $0) },
                isActive: $showingOrderForm
            ) {
                EmptyView()
            }
        }
        .navigationTitle("Drink Selection")
        .navigationBarTitleDisplayMode(.inline)
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
    }
}

// Drink Option Card Component
struct DrinkOptionCard: View {
    let drink: DrinkType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(systemName: drink.iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .foregroundColor(isSelected ? .white : AppColors.primary)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(drink.rawValue)
                        .font(.headline)
                        .foregroundColor(isSelected ? .white : AppColors.textPrimary)
                    
                    Text(drink.description)
                        .font(.subheadline)
                        .foregroundColor(isSelected ? .white.opacity(0.9) : AppColors.textSecondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                        .font(.title3)
                }
            }
            .padding()
            .background(isSelected ? AppColors.primary : AppColors.secondaryBackground)
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(isSelected ? AppColors.primary : Color.clear, lineWidth: 2)
            )
            .shadow(color: isSelected ? AppColors.primary.opacity(0.3) : Color.clear, radius: 5)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : [.isButton])
        .accessibilityHint("Tap to select \(drink.rawValue)")
    }
}

#Preview {
    DrinkSelectionView()
} 