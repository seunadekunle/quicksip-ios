//
//  OrderRow.swift
//  QuickSip
//
//  Created by Seun Adekunle on 4/12/25.
//

import SwiftUI

struct OrderRowView: View {
    let order: Order
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(order.drinkType)
                    .font(.headline)
                
                Text("Location: \(order.location)")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text(formattedDate)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 5) {
                // Status indicator
                Text(order.status.capitalized)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.2))
                    .foregroundColor(statusColor)
                    .cornerRadius(5)
                
                // Price
                Text(String(format: "$%.2f", order.price))
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
    
    // Format the timestamp
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        
        return formatter.string(from: order.timestamp)
    }
    
    // Status color based on order status
    private var statusColor: Color {
        switch order.status.lowercased() {
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