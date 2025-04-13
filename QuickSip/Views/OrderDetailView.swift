//
//  OrderDetailView.swift
//  QuickSip
//
//  Created by Seun Adekunle on 4/12/25.
//

import SwiftUI

struct OrderDetailView: View {
    let order: Order
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Order header
                VStack(alignment: .center, spacing: 5) {
                    Image(systemName: "cup.and.saucer.fill")
                        .font(.system(size: 60))
                        .foregroundColor(AppColors.primary)
                        .padding(.bottom, 10)
                    
                    Text(order.drinkType)
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    VStack(spacing: 6) {
                        Text("Order #\(order.id.prefix(6).uppercased())")
                            .font(.subheadline)
                        
                        HStack {
                            Text(formattedDate)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        StatusBadge(status: order.status)
                            .padding(.top, 5)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppColors.secondaryBackground)
                .cornerRadius(12)
                
                // Order details
                VStack(alignment: .leading, spacing: 15) {
                    SectionHeader(title: "Order Details")
                    
                    DetailRow(label: "Drink", value: order.drinkType)
                    DetailRow(label: "Size", value: order.size)
                    
                    if !order.milk.isEmpty {
                        DetailRow(label: "Milk", value: order.milk)
                    }
                    
                    if !order.flavor.isEmpty {
                        DetailRow(label: "Flavor", value: order.flavor)
                    }
                    
                    if order.isIced {
                        DetailRow(label: "Temperature", value: "Iced")
                    } else {
                        DetailRow(label: "Temperature", value: "Hot")
                    }
                    
                    DetailRow(label: "Amount", value: String(format: "$%.2f", order.price))
                    DetailRow(label: "Location", value: order.location)
                }
                .padding()
                .background(AppColors.secondaryBackground)
                .cornerRadius(12)
                
                // Order timeline
                VStack(alignment: .leading, spacing: 15) {
                    SectionHeader(title: "Order Timeline")
                    
                    OrderTimelineView(status: order.status)
                }
                .padding()
                .background(AppColors.secondaryBackground)
                .cornerRadius(12)
            }
            .padding()
        }
        .navigationTitle("Order Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Order Details")
                    .font(.headline)
                    .foregroundColor(AppColors.primary)
            }
        }
    }
    
    // Format the timestamp
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        
        return formatter.string(from: order.timestamp)
    }
}

// Status badge component
struct StatusBadge: View {
    let status: String
    
    var body: some View {
        Text(status.capitalized)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(statusColor.opacity(0.2))
            .foregroundColor(statusColor)
            .cornerRadius(20)
    }
    
    // Status color based on order status
    private var statusColor: Color {
        switch status.lowercased() {
        case "pending":
            return .orange
        case "preparing":
            return .blue
        case "ready":
            return .green
        case "delivered":
            return .green
        case "cancelled":
            return .red
        default:
            return .gray
        }
    }
}

// Section header component
struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.headline)
            .foregroundColor(AppColors.primary)
            .padding(.bottom, 5)
    }
}

// Detail row component
struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.gray)
                .frame(width: 100, alignment: .leading)
            
            Text(value)
                .font(.subheadline)
            
            Spacer()
        }
        .padding(.vertical, 3)
    }
}

// Order timeline component
struct OrderTimelineView: View {
    let status: String
    
    var body: some View {
        VStack(spacing: 0) {
            timelineStep(
                icon: "cart.fill",
                title: "Order Placed",
                isActive: true,
                isFirst: true,
                isLast: false
            )
            
            timelineStep(
                icon: "timer",
                title: "Preparing",
                isActive: isActiveStep("preparing"),
                isFirst: false,
                isLast: false
            )
            
            timelineStep(
                icon: "checkmark.circle.fill",
                title: "Ready for Pickup",
                isActive: isActiveStep("ready"),
                isFirst: false,
                isLast: false
            )
            
            timelineStep(
                icon: "hand.thumbsup.fill",
                title: "Delivered",
                isActive: isActiveStep("delivered"),
                isFirst: false,
                isLast: true
            )
        }
    }
    
    private func isActiveStep(_ step: String) -> Bool {
        let statusLower = status.lowercased()
        
        switch statusLower {
        case "pending":
            return false
        case "preparing":
            return step == "preparing"
        case "ready":
            return step == "preparing" || step == "ready"
        case "delivered":
            return true
        case "cancelled":
            return false
        default:
            return false
        }
    }
    
    private func timelineStep(icon: String, title: String, isActive: Bool, isFirst: Bool, isLast: Bool) -> some View {
        HStack(spacing: 15) {
            // Timeline line and icon
            VStack {
                if !isFirst {
                    Rectangle()
                        .frame(width: 2)
                        .foregroundColor(isActive ? AppColors.primary : Color.gray.opacity(0.3))
                        .frame(height: 30)
                }
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .frame(width: 35, height: 35)
                    .background(isActive ? AppColors.primary : Color.gray.opacity(0.3))
                    .foregroundColor(.white)
                    .cornerRadius(20)
                
                if !isLast {
                    Rectangle()
                        .frame(width: 2)
                        .foregroundColor(isActive && !isLast ? AppColors.primary : Color.gray.opacity(0.3))
                        .frame(height: 30)
                }
            }
            
            // Step text
            Text(title)
                .font(.subheadline)
                .foregroundColor(isActive ? .primary : .gray)
                .fontWeight(isActive ? .medium : .regular)
                .padding(.vertical, 10)
            
            Spacer()
        }
    }
}

//#Preview {
//    let sampleOrder = Order(
//        id: "12345",
//        userId: "user123",
//        drinkType: "Caramel Latte",
//        size: "Medium",
//        milk: "Oat",
//        flavor: "Caramel",
//        isIced: true,
//        price: 4.99,
//        location: "Downtown Store",
//        status: "preparing",
//        timestamp: Date()
//    )
//    
//    return NavigationStack {
//        OrderDetailView(order: sampleOrder)
//    }
//} 
